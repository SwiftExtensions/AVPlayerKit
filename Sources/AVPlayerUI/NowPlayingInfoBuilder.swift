//
//  NowPlayingInfoBuilder.swift
//

import UIKit
import MediaPlayer

/**
 Класс для создания словаря с информацией о текущем плеере.
 
 Пример использования:
 ```swift
 import MediaPlayer
 
 var nowPlayingInfoBuilder = NowPlayingInfoBuilder(
    title: "My Title",
    artist: "My Artist"
 )
 nowPlayingInfoBuilder.setArtwork(UIImage(named: "artwork"))
 
 MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfoBuilder.build()
 ```
 */
public struct NowPlayingInfoBuilder {
    /**
     Заголовок медиа.
     */
    public var title: String?
    /**
     Исполнитель медиа.
     */
    public var artist: String?
    /**
     Изображение медиа.
     */
    public var artwork: MPMediaItemArtwork?
    /**
     Тип медиа.
     */
    public var mediaType: MPNowPlayingInfoMediaType = .none
    /**
     Значение, указывающее, что медиа в прямом эфире.
     */
    public var isLiveStream: Bool?
    
    /**
     Создать словарь с информацией о текущем плеере.
     - Parameter title: Заголовок медиа.
     - Parameter artist: Исполнитель медиа.
     */
    public init(title: String?, artist: String?) {
        self.title = title
        self.artist = artist
    }
    
    /**
     Установить изображение медиа.
     - Parameter image: Изображение медиа.
     */
    public mutating func setArtwork(_ image: UIImage?) {
        guard let image else { return }
        self.artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { _ in image })
    }
    /**
     Установить изображение медиа.
     - Parameter data: Изображение медиа.
     */
    public mutating func setArtwork(_ data: Data?) {
        guard let data else { return }
        
        let image = UIImage(data: data)
        self.setArtwork(image)
    }
    /**
     Создать словарь с информацией о текущем плеере.
     Пример использования:
     ```swift
     import MediaPlayer
     
     var nowPlayingInfoBuilder = NowPlayingInfoBuilder(
        title: "My Title",
        artist: "My Artist"
     )
     nowPlayingInfoBuilder.setArtwork(UIImage(named: "artwork"))
     
     MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfoBuilder.build()
     */
    public func build() -> [String : Any] {
        var nowPlayingInfo: [String : Any] = [:]
        nowPlayingInfo[MPMediaItemPropertyTitle] = self.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = self.artist
        nowPlayingInfo[MPMediaItemPropertyArtwork] = self.artwork
        nowPlayingInfo[MPNowPlayingInfoPropertyMediaType] = self.mediaType.rawValue
        nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = self.isLiveStream
        return nowPlayingInfo
    }
    
    
}
