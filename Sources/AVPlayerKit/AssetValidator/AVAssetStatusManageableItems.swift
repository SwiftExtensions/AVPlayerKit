//
//  AVAssetStatusManageableItems.swift
//  AVPlayerContainerKit
//
//  Created by Александр Алгашев on 30.10.2026.
//

import Foundation

/**
 Коллекция проверяемых ресурсов с управлением состояниями.

 Предоставляет валидатору доступ к адресу и состоянию элементов по индексу.
 Индексом может быть любой хэшируемый тип, например `Int` или `IndexPath`.
 */
public protocol AVAssetStatusManageableItems: AnyObject {
    /**
     Тип индекса элемента.
     */
    associatedtype Index: Hashable
    /**
     Возвращает адрес ресурса по индексу.

     - Parameter index: Индекс элемента.
     - Returns: Адрес ресурса.
     */
    func url(at index: Index) -> URL
    /**
     Возвращает состояние элемента по индексу.

     - Parameter index: Индекс элемента.
     - Returns: Текущее состояние.
     */
    func status(at index: Index) -> AVAssetStatus
    /**
     Задаёт состояние элемента по индексу.

     - Parameter status: Новое состояние.
     - Parameter index: Индекс элемента.
     */
    func setStatus(_ status: AVAssetStatus, at index: Index)


}


