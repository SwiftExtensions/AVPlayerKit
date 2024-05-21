//
//  AVPlayerItem.swift
//

import AVFoundation

public extension AVPlayerItem {
    convenience init?(urlString: String, httpHeaderFields headers: [String: String]? = nil) {
        guard let url = URL(string: urlString) else { return nil }
        let options = headers.map { [AVURLAssetHTTPHeaderFieldsKey : $0] }
        let asset = AVURLAsset(url: url, options: options)
        self.init(asset: asset)
    }
}
