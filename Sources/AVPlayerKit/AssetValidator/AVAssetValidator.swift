//
//  AVAssetValidator.swift
//  AVPlayerContainerKit
//
//  Created by Александр Алгашев on 30.10.2026.
//

import AVFoundation
import Foundation

/**
 Валидатор ресурсов `AVAsset`.

 Хранит очередь проверки ресурсов по запросам, последовательно проверяет их
 и выдаёт индексы элементов, у которых изменилось состояние.
 */
public final class AVAssetValidator<Items: AVAssetStatusManageableItems> {
    /**
     Максимальное время ожидания проверки одного ресурса в секундах.
     */
    private let timeout: TimeInterval
    /**
     Коллекция проверяемых ресурсов с управлением состояниями.
     */
    private let items: Items
    /**
     Проверяет пригодность ресурса по адресу.

     - Parameter url: Адрес ресурса.
     */
    private let validate: (URL) async throws -> Void

    /**
     Индексы элементов с активным запросом на проверку.
     */
    private var activeRequests: Set<Items.Index> = []
    /**
     Очередь индексов элементов для проверки.
     */
    private var validationChannel: AsyncStream<Items.Index>.Continuation?
    /**
     Индексы, ожидающие создания очереди проверки, в порядке поступления
     запросов.
     */
    private var pendingValidationIndices: [Items.Index] = []
    /**
     Задача последовательной проверки ресурсов по запросам.
     */
    private var validationLoopTask: Task<Void, Never>?
    /**
     Продолжение последовательности изменений состояния ресурсов.
     */
    private var changesContinuation: AsyncThrowingStream<Items.Index, any Error>.Continuation?
    /**
     Индекс элемента, проверяемого в данный момент.
     */
    private var currentValidationIndex: Items.Index?
    /**
     Задача проверки текущего ресурса.
     */
    private var currentValidationTask: Task<Void, Never>?
    /**
     Индекс элемента с приоритетной проверкой.
     */
    private var priorityValidationIndex: Items.Index?

    /**
     Создаёт валидатор ресурсов.

     - Parameter items: Коллекция проверяемых ресурсов с управлением
       состояниями.
     - Parameter timeout: Максимальное время ожидания проверки одного ресурса
       в секундах.
     */
    public convenience init(items: Items, timeout: TimeInterval) {
        self.init(items: items, timeout: timeout) { url in
            try await AVAsset(url: url).validatePlayability(timeout: timeout)
        }
    }

    /**
     Создаёт валидатор ресурсов с пользовательской проверкой пригодности.

     - Parameter items: Коллекция проверяемых ресурсов с управлением
       состояниями.
     - Parameter timeout: Максимальное время ожидания проверки одного ресурса
       в секундах.
     - Parameter validate: Замыкание проверки пригодности ресурса по адресу.
       Завершается успешно, если ресурс пригоден для воспроизведения,
       или с ошибкой — иначе.
     */
    init(
        items: Items,
        timeout: TimeInterval,
        validate: @escaping (URL) async throws -> Void
    ) {
        self.items = items
        self.timeout = timeout
        self.validate = validate
    }

    /**
     Проверяет ресурсы по очереди запросов и выдаёт индексы элементов,
     у которых изменилось состояние.

     Очередь проверки формируется из запросов и меняется во время работы:
     новые запросы добавляются, а отменённые удаляются. Проверяемый ресурс
     с отменённым запросом прерывается, и проверка переходит к следующему
     в очереди. Ресурсы с известным состоянием не проверяются.

     - Returns: Асинхронная последовательность индексов изменённых элементов.
     */
    public func changes() -> AsyncThrowingStream<Items.Index, any Error> {
        AsyncThrowingStream { continuation in
            self.changesContinuation = continuation
            let channel = AsyncStream<Items.Index> { channelContinuation in
                self.validationChannel = channelContinuation
                // выдаём индексы, накопившиеся до создания очереди
                for index in self.pendingValidationIndices {
                    channelContinuation.yield(index)
                }
                self.pendingValidationIndices.removeAll()
            }
            let task = Task {
                await self.validationLoop(channel)
            }
            self.validationLoopTask = task
            // отменяем проверку, если потребитель прекратил итерацию
            continuation.onTermination = { [weak self] _ in
                task.cancel()
                self?.currentValidationTask?.cancel()
            }
        }
    }
    /**
     Запрашивает проверку ресурса по индексу.

     Если состояние ресурса ещё неизвестно, он ставится в очередь проверки.
     Для ресурсов с известным состоянием или с активным запросом запрос
     не создаётся.

     - Parameter index: Индекс элемента.
     */
    public func requestValidation(at index: Items.Index) {
        guard case .unknown = self.items.status(at: index) else { return }
        guard self.activeRequests.insert(index).inserted else { return }

        if let channel = self.validationChannel {
            channel.yield(index)
        } else {
            self.pendingValidationIndices.append(index)
        }
    }
    /**
     Отменяет запрос на проверку ресурса по индексу.

     Ресурс удаляется из очереди, а если он проверялся в данный момент,
     проверка прерывается.

     - Parameter index: Индекс элемента.
     */
    public func cancelValidation(at index: Items.Index) {
        self.activeRequests.remove(index)
        if self.currentValidationIndex == index {
            self.currentValidationTask?.cancel()
        }
    }
    /**
     Назначает ресурс приоритетным для проверки по индексу.

     Текущая проверка отменяется, а её ресурс возвращается в очередь.
     Указанный ресурс проверяется следующим, остальные — после него.

     - Parameter index: Индекс элемента.
     */
    public func prioritizeValidation(at index: Items.Index) {
        guard case .unknown = self.items.status(at: index) else { return }

        self.priorityValidationIndex = index
        // возвращаем прерываемый ресурс в очередь проверки
        if let current = self.currentValidationIndex, current != index {
            self.validationChannel?.yield(current)
        }
        // прерываем текущую проверку, чтобы цикл перешёл к приоритетному ресурсу
        self.currentValidationTask?.cancel()
        // будим цикл проверки
        self.validationChannel?.yield(index)
    }
    /**
     Забирает индексы из очереди и последовательно проверяет их.

     Ресурсы с отменённым запросом или уже проверенные пропускаются.
     По завершении очереди последовательность закрывается.

     - Parameter channel: Очередь индексов для проверки.
     */
    private func validationLoop(_ channel: AsyncStream<Items.Index>) async {
        for await index in channel {
            // сначала проверяем приоритетный ресурс, если он назначен
            if let priority = self.priorityValidationIndex {
                self.priorityValidationIndex = nil
                await self.performValidationIfNeeded(at: priority)
            }
            await self.performValidationIfNeeded(at: index)
        }
        self.changesContinuation?.finish()
    }
    /**
     Проверяет ресурс по указанному индексу, если запрос на проверку активен
     и состояние ещё неизвестно.

     Ресурсы с отменённым запросом или известным состоянием пропускаются.

     - Parameter index: Индекс элемента.
     */
    private func performValidationIfNeeded(at index: Items.Index) async {
        guard self.activeRequests.contains(index) else { return }
        guard case .unknown = self.items.status(at: index) else { return }
        await self.performValidation(at: index)
    }
    /**
     Проверяет ресурс по указанному индексу и выдаёт индекс в последовательность
     изменений при каждом изменении состояния.

     Проверка выполняется в отдельной задаче, чтобы её можно было отменить
     при отмене запроса. При отмене ресурс возвращается в состояние `.unknown`.

     - Parameter index: Индекс проверяемого ресурса.
     */
    private func performValidation(at index: Items.Index) async {
        self.items.setStatus(.processing, at: index)
        self.currentValidationIndex = index
        self.changesContinuation?.yield(index)

        let task = Task {
            let status: AVAssetStatus
            do {
                try await self.validate(self.items.url(at: index))
                status = .readyToPlay
            } catch is CancellationError {
                // проверка отменена — ресурс возвращается в состояние «не проверялся»
                status = .unknown
            } catch {
                status = .failed(error)
            }
            self.items.setStatus(status, at: index)
            self.changesContinuation?.yield(index)
        }
        self.currentValidationTask = task
        await task.value
        self.currentValidationTask = nil
        self.currentValidationIndex = nil
    }


}


