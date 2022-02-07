//
//  Configuration.swift
//  ApiVideoLiveStream
//

import Foundation

public class Resolution{
    public var width: Int
    public var height: Int

    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
}

public enum Resolutions {
    case RESOLUTION_240
    case RESOLUTION_360
    case RESOLUTION_480
    case RESOLUTION_720
    case RESOLUTION_1080
    case RESOLUTION_2160

    public var instance: Resolution{
        switch self {
        case .RESOLUTION_240:
            return Resolution(width: 352, height: 240)
        case .RESOLUTION_360:
            return Resolution(width: 480, height: 360)
        case .RESOLUTION_480:
            return Resolution(width: 858, height: 480)
        case .RESOLUTION_720:
            return Resolution(width: 1280, height: 720)
        case .RESOLUTION_1080:
            return Resolution(width: 1920, height: 1080)
        case .RESOLUTION_2160:
            return Resolution(width: 3860, height: 2160)
        }
    }
}

public struct AudioConfig {
    public let bitrate: Int
    
    public init(bitrate: Int) {
        self.bitrate = bitrate
    }
}

public struct VideoConfig {
    public let bitrate: Int
    public let resolution: Resolutions
    public let fps: Int
    
    public init(bitrate: Int, resolution: Resolutions, fps: Int) {
        self.bitrate = bitrate
        self.resolution = resolution
        self.fps = fps
    }
}
