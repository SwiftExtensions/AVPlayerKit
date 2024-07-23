//
//  RemoteCommandCenter.swift
//

import MediaPlayer

/**
 Класс для дистанционного управления командами плеера.
 
 Пример использования:
 ```swift
 let remoteCommandCenter = RemoteCommandCenter()
 remoteCommandCenter.addAction(\.playCommand) { event in
    // Обработать событие полученное от внешнего медиа плеера.
    ...
    return .success
 }
 ```
 */
public class RemoteCommandCenter {
    /**
     Блок, вызываемый при выполнении команды.
     Принимает событие полученное от внешнего медиа плеера и
     возвращает статус команды.
     */
    public typealias CommandAction = (_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus
    
    /**
     Объект взаимодействующий с дистаннционными событиями плеера.
     */
    public let commandCenter: MPRemoteCommandCenter
    /**
     Доступность дистанционного управления командами плеера.
     
     Значение по умолчаню `true`.
     */
    public var isEnabled: Bool = true {
        didSet { self.isEnabled ? self.enableActions() : self.disableActions() }
    }
    /**
     Список установленных команд управления плеером.
     */
    private var commands: [KeyPath<MPRemoteCommandCenter, MPRemoteCommand> : CommandAction] = [:]
    /**
     Токены установленных команд управления плеером.
     */
    private var tokens: [KeyPath<MPRemoteCommandCenter, MPRemoteCommand> : Any] = [:]
    
    /**
     Создать экзепляр дистанционного управления командами плеера.
     - Parameter commandCenter: Объект взаимодействующий с дистаннционными событиями плеера.
     */
    public init(commandCenter: MPRemoteCommandCenter = .shared()) {
        self.commandCenter = commandCenter
    }
    
    /**
     Добавить действие дистанционного управления плеером для указанной команды.
     - Parameter keyPath: Ключевой путь для команды.
     - Parameter action: Блок, вызываемый при выполнении команды.
     
     Пример использования:
     ```swift
     let remoteCommandCenter = RemoteCommandCenter()
     remoteCommandCenter.addAction(\.playCommand) { event in
        // Обработать событие полученное от внешнего медиа плеера.
        ...
        return .success
     }
     ```
     */
    public func addAction(
        to keyPath: KeyPath<MPRemoteCommandCenter, MPRemoteCommand>,
        action: @escaping CommandAction
    ) {
        self.commands[keyPath] = action
        if self.isEnabled {
            let token = self.commandCenter[keyPath: keyPath].addTarget(handler: action)
            self.commandCenter[keyPath: keyPath].isEnabled = true
            self.tokens[keyPath] = token
        }
    }
    /**
     Удалить действие дистанционного управления плеером для указанной команды.
     - Parameter keyPath: Ключевой путь для команды.
     
     Пример использования:
    ``` swift
     let remoteCommandCenter = RemoteCommandCenter()
     remoteCommandCenter.addAction(\.playCommand) { event in
        // Обработать событие полученное от внешнего медиа плеера.
        ...
        return .success
     }
     ...
     remoteCommandCenter.removeAction(\.playCommand)
     ```
     */
    public func removeAction(
        from keyPath: KeyPath<MPRemoteCommandCenter, MPRemoteCommand>
    ) {
        if let token = self.tokens[keyPath] {
            self.commandCenter[keyPath: keyPath].removeTarget(token)
            self.commandCenter[keyPath: keyPath].isEnabled = false
        }
    }
    /**
     Активирует команды дистанционного управления плеером.
     */
    private func enableActions() {
        self.commands.forEach { keyPath, action in
            let token = self.commandCenter[keyPath: keyPath].addTarget(handler: action)
            self.commandCenter[keyPath: keyPath].isEnabled = true
            tokens[keyPath] = token
        }
    }
    /**
     Отключает команды дистанционного управления плеером.
     - Parameter isEnabled: Возможность взаимодействия с командой.
     */
    private func disableActions(isEnabledCommand isEnabled: Bool = false) {
        self.commands.forEach { keyPath, _ in
            if let token = self.tokens[keyPath] {
                self.commandCenter[keyPath: keyPath].removeTarget(token)
                self.commandCenter[keyPath: keyPath].isEnabled = isEnabled
            }
        }
        self.tokens.removeAll()
    }
    
    deinit {
        self.disableActions(isEnabledCommand: true)
    }
    
    
}
