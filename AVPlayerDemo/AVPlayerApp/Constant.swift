//
//  Constant.swift
//  AVPlayerDemo
//
//  Created by Александр Алгашев on 11.12.2025.
//


import Foundation

struct Constant {
    private init() {}
    
    static let stream = Stream.bridgeTV
    
    struct Stream {
        let url: URL
        let title: String
        
        static let bridgeTV = Stream(
            url: URL(string: "http://31.148.48.15/Bridge_TV/index.m3u8")!,
            title: "Bridge TV"
        )
        static let songTV = Stream(
            url: URL(string: "https://songtv.hls.iptvdc.com/web-russia/index.m3u8")!,
            title: "Song TV"
        )
        static let ruTV = Stream(
            url: URL(string: "https://hls-03-video.webcaramba.com/rutv/live_480/index.m3u8")!,
            title: "RU TV"
        )
        static let ruTVHD = Stream(
            url: URL(string: "https://hls-03-video.webcaramba.com/rutv/live_1080/index.m3u8")!,
            title: "RU TV HD"
        )
        static let dateRangeDebug = Stream(
            url: URL(string: "https://qa.iptv2022.com/out/custom_datarange.m3u8")!,
            title: "Тест меток Date Range"
        )
        
        
    }
    
    
}
