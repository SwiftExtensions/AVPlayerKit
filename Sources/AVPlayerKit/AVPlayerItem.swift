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
    
    
}
