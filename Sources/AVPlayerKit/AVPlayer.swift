//
//  AVPlayer.swift
//  

import AVFoundation

public extension AVPlayer {
    /**
     Создает новый проигрыватель для воспроизведения одного аудиовизуального ресурса,
     на который ссылается строковое значение URL-адреса.
     - Parameter urlString: Строковое значение URL-адреса, идентифицирующее аудиовизуальный ресурс.
     */
    convenience init?(urlString: String) {
        if let url = URL(string: urlString) {
            self.init(url: url)
        } else {
            return nil
        }
    }
    /**
     Заменять текущий элемент воспрозведениям новым, с указанным URL.
     
     Элемент воспроизведения плеера заменяется немедленно
     и новый элемент становится текущим элементом воспроизведения плеера
     [currentItem](https://developer.apple.com/documentation/avfoundation/avplayer/1387569-currentitem).
     
     - Parameter url: URL  указывающий на медиа ресурс для воспроизведения.
     */
    @discardableResult
    func replaceCurrentItem(with url: URL) -> AVPlayerItem {
        let playerItem = AVPlayerItem(url: url)
        self.replaceCurrentItem(with: playerItem)
        
        return playerItem
    }
    /**
     Заменять текущий элемент воспрозведениям новым,
     с указанным строковым представлением URL.
     
     Элемент воспроизведения плеера заменяется немедленно
     и новый элемент становится текущим элементом воспроизведения плеера
     [currentItem](https://developer.apple.com/documentation/avfoundation/avplayer/1387569-currentitem).
     
     Строковое представление должно представлять корректное URL.
     
     - Parameter urlString: URL указывающий на медиа ресурс для воспроизведения.
     */
    @discardableResult
    func replaceCurrentItem(with urlString: String) -> AVPlayerItem? {
        var playerItem: AVPlayerItem?
        if let url = URL(string: urlString) {
            playerItem = self.replaceCurrentItem(with: url)
        }
        
        return playerItem
    }
    
    
}
