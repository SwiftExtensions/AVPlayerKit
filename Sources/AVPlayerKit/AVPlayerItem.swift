//
//  AVPlayerItem.swift
//

import AVFoundation

public extension AVPlayerItem {
    /**
     Initializes an `AVPlayerItem` with a URL string and optional HTTP header fields.
     
     - Parameters:
        - urlString: The string representation of the URL for the media resource.
        - headers: An optional dictionary of HTTP header fields to be used when loading the resource.
     - Returns: An initialized `AVPlayerItem` if the URL is valid; otherwise, returns `nil`.
     */
    convenience init?(urlString: String, httpHeaderFields headers: [String: String]? = nil) {
        guard let url = URL(string: urlString) else { return nil }
        let options = headers.map { [AVURLAssetHTTPHeaderFieldsKey : $0] }
        let asset = AVURLAsset(url: url, options: options)
        self.init(asset: asset)
    }
    
    /**
     The accumulated duration, in seconds, of the media played.
     */
    @inlinable
    @inline(__always)
    func durationWatched() -> TimeInterval? {
        self.accessLog()?.events.map(\.durationWatched).reduce(0, +)
    }
    /**
     Суммарное количество байт, загруженных элементом воспроизведения.
     
     Значение вычисляется по событиям
     [журнала доступа](https://developer.apple.com/documentation/avfoundation/avplayeritemaccesslog)
     и позволяет оценить объём данных, полученных из сети.
     
     - Returns: Общее количество загруженных байт или `nil`,
       если журнал доступа отсутствует либо ещё не содержит событий.
     */
    func totalBytesTransferred() -> Int64? {
        guard let events = self.accessLog()?.events, !events.isEmpty else {
            return nil
        }
        
        return events.reduce(Int64(0)) {
            $0 + Int64($1.numberOfBytesTransferred)
        }
    }
    /**
     Длительность контента в секундах, загруженного вперёд от текущей позиции.
     
     Значение вычисляется по последнему диапазону
     [loadedTimeRanges](https://developer.apple.com/documentation/avfoundation/avplayeritem/1387554-loadedtimeranges)
     относительно текущей позиции воспроизведения.
     
     - Returns: Количество секунд буферизованных данных или `nil`,
       если диапазоны загруженного времени недоступны.
     */
    func bufferedAhead() -> TimeInterval? {
        guard let range = self.loadedTimeRanges.last?.timeRangeValue else {
            return nil
        }
        
        let ahead = CMTimeGetSeconds(range.end) - self.currentTime().seconds
        
        return max(ahead, 0.0)
    }
    
    
}
