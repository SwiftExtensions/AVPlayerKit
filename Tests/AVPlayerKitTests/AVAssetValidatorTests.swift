//
//  AVAssetValidatorTests.swift
//  AVPlayerContainerKit
//
//  Created by Александр Алгашев on 30.10.2026.
//

import XCTest
@testable import AVPlayerKit

/**
 Ошибка превышения времени ожидания в тестах.
 */
private struct TestTimeoutError: Error {}


/**
 Мок коллекции проверяемых ресурсов с индексами `Int`.
 */
private final class MockItems: AVAssetStatusManageableItems {
    typealias Index = Int

    /**
     Адреса ресурсов по индексам.
     */
    private let urls: [Int: URL]
    /**
     Состояния ресурсов по индексам.
     */
    private var statuses: [Int: AVAssetStatus] = [:]
    /**
     Количество попыток проверки по индексам.
     */
    private var attempts: [Int: Int] = [:]
    /**
     Блокировка синхронизации доступа из параллельных задач.
     */
    private let lock = NSLock()

    /**
     Создаёт мок коллекции.

     - Parameter urls: Адреса ресурсов по индексам.
     */
    init(urls: [Int: URL]) {
        self.urls = urls
    }

    func url(at index: Int) -> URL {
        self.urls[index]!
    }
    func status(at index: Int) -> AVAssetStatus {
        self.lock.lock()
        defer { self.lock.unlock() }
        return self.statuses[index] ?? .unknown
    }
    func setStatus(_ status: AVAssetStatus, at index: Int) {
        self.lock.lock()
        defer { self.lock.unlock() }
        self.statuses[index] = status
    }
    /**
     Регистрирует попытку проверки ресурса.

     - Parameter index: Индекс элемента.
     */
    func recordAttempt(at index: Int) {
        self.lock.lock()
        defer { self.lock.unlock() }
        self.attempts[index, default: 0] += 1
    }
    /**
     Возвращает количество попыток проверки ресурса.

     - Parameter index: Индекс элемента.
     - Returns: Количество попыток проверки.
     */
    func attemptsCount(at index: Int) -> Int {
        self.lock.lock()
        defer { self.lock.unlock() }
        return self.attempts[index] ?? 0
    }


}


final class AVAssetValidatorTests: XCTestCase {
    /**
     Собирает из последовательности изменений указанное количество событий.

     Все ожидания в тестах ограничены по времени: если за `timeout` секунд
     собрано меньше событий, выбрасывается `TestTimeoutError` и тест падает,
     а не зависает навсегда.

     - Parameter stream: Последовательность изменений.
     - Parameter count: Ожидаемое количество событий.
     - Parameter timeout: Время ожидания в секундах.
     - Parameter onEvent: Замыкание, вызываемое после каждого полученного
       события, например для отмены проверки в нужный момент.
     - Returns: Собранные индексы.
     */
    private func collect(
        _ stream: AsyncThrowingStream<Int, any Error>,
        until count: Int,
        timeout: TimeInterval = 5,
        onEvent: (([Int]) -> Void)? = nil
    ) async throws -> [Int] {
        try await withThrowingTaskGroup(of: [Int].self) { group in
            group.addTask {
                var events: [Int] = []
                for try await index in stream {
                    events.append(index)
                    onEvent?(events)
                    if events.count == count { break }
                }
                return events
            }
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                throw TestTimeoutError()
            }
            guard let events = try await group.next() else {
                throw TestTimeoutError()
            }
            group.cancelAll()
            return events
        }
    }

    func testValidationSuccess() async throws {
        let items = MockItems(urls: [1: URL(string: "https://example.com/1")!])
        let validator = AVAssetValidator(items: items, timeout: 5) { _ in
            items.recordAttempt(at: 1)
        }
        let changes = validator.changes()

        validator.requestValidation(at: 1)
        let events = try await self.collect(changes, until: 2)

        XCTAssertEqual(events, [1, 1])
        guard case .readyToPlay = items.status(at: 1) else {
            return XCTFail("Ожидалось состояние .readyToPlay")
        }
        XCTAssertEqual(items.attemptsCount(at: 1), 1)
    }

    func testValidationFailure() async throws {
        let items = MockItems(urls: [1: URL(string: "https://example.com/1")!])
        let validator = AVAssetValidator(items: items, timeout: 5) { _ in
            throw URLError(.badURL)
        }
        let changes = validator.changes()

        validator.requestValidation(at: 1)
        _ = try await self.collect(changes, until: 2)

        guard case .failed = items.status(at: 1) else {
            return XCTFail("Ожидалось состояние .failed")
        }
    }

    func testDuplicateRequestIgnored() async throws {
        let items = MockItems(urls: [1: URL(string: "https://example.com/1")!])
        let validator = AVAssetValidator(items: items, timeout: 5) { _ in
            items.recordAttempt(at: 1)
        }
        let changes = validator.changes()

        validator.requestValidation(at: 1)
        validator.requestValidation(at: 1)
        let events = try await self.collect(changes, until: 2)

        XCTAssertEqual(events, [1, 1])
        XCTAssertEqual(items.attemptsCount(at: 1), 1)
    }

    func testRequestsBeforeChangesAreBuffered() async throws {
        let items = MockItems(urls: [
            1: URL(string: "https://example.com/1")!,
            2: URL(string: "https://example.com/2")!,
        ])
        let validator = AVAssetValidator(items: items, timeout: 5) { _ in }

        validator.requestValidation(at: 1)
        validator.requestValidation(at: 2)
        let events = try await self.collect(validator.changes(), until: 4)

        XCTAssertEqual(events, [1, 1, 2, 2])
    }

    func testCancelValidation() async throws {
        let items = MockItems(urls: [1: URL(string: "https://example.com/1")!])
        let validator = AVAssetValidator(items: items, timeout: 5) { _ in
            items.recordAttempt(at: 1)
            // проверка «зависает», пока её не отменят
            try await Task.sleep(nanoseconds: 10_000_000_000)
        }
        let changes = validator.changes()

        validator.requestValidation(at: 1)
        let events = try await self.collect(changes, until: 2) { events in
            if events.count == 1 {
                validator.cancelValidation(at: 1)
            }
        }

        XCTAssertEqual(events, [1, 1])
        guard case .unknown = items.status(at: 1) else {
            return XCTFail("Ожидалось состояние .unknown после отмены")
        }
        XCTAssertEqual(items.attemptsCount(at: 1), 1)
    }

    func testKnownStatusSkipped() async throws {
        let items = MockItems(urls: [1: URL(string: "https://example.com/1")!])
        items.setStatus(.readyToPlay, at: 1)
        let validator = AVAssetValidator(items: items, timeout: 5) { _ in }
        let changes = validator.changes()

        validator.requestValidation(at: 1)

        await XCTAssertThrowsErrorAsync(
            try await self.collect(changes, until: 1, timeout: 0.5)
        )
        XCTAssertEqual(items.attemptsCount(at: 1), 0)
    }

    func testPrioritizeValidation() async throws {
        let items = MockItems(urls: [
            1: URL(string: "https://example.com/1")!,
            2: URL(string: "https://example.com/2")!,
        ])
        let validator = AVAssetValidator(items: items, timeout: 5) { url in
            // проверка первого ресурса «зависает», пока её не отменят
            if url.absoluteString.hasSuffix("1") {
                try await Task.sleep(nanoseconds: 10_000_000_000)
            }
        }
        let changes = validator.changes()

        validator.requestValidation(at: 1)
        validator.requestValidation(at: 2)
        let events = try await self.collect(changes, until: 4) { events in
            if events.count == 1 {
                validator.prioritizeValidation(at: 2)
                validator.cancelValidation(at: 1)
            }
        }

        XCTAssertEqual(events, [1, 1, 2, 2])
        guard case .unknown = items.status(at: 1) else {
            return XCTFail("Ожидалось состояние .unknown после отмены")
        }
        guard case .readyToPlay = items.status(at: 2) else {
            return XCTFail("Ожидалось состояние .readyToPlay")
        }
    }
}


/**
 Проверяет, что замыкание выбрасывает ошибку, в асинхронном контексте.
 */
private func XCTAssertThrowsErrorAsync<T>(
    _ expression: @autoclosure () async throws -> T,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        _ = try await expression()
        XCTFail("Ожидалась ошибка, но замыкание завершилось успешно", file: file, line: line)
    } catch {
        // ошибка получена — проверка пройдена
    }
}
