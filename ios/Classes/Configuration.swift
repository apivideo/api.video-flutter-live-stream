//
//  Configuration.swift
//  ApiVideoLiveStream
//

import Foundation
import Network

public class Size{
    public var width: Int
    public var height: Int

    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
}

public enum Resolution {
    case RESOLUTION_240
    case RESOLUTION_360
    case RESOLUTION_480
    case RESOLUTION_720
    case RESOLUTION_1080

    public var instance: Size{
        switch self {
        case .RESOLUTION_240:
            return Size(width: 352, height: 240)
        case .RESOLUTION_360:
            return Size(width: 480, height: 360)
        case .RESOLUTION_480:
            return Size(width: 858, height: 480)
        case .RESOLUTION_720:
            return Size(width: 1280, height: 720)
        case .RESOLUTION_1080:
            return Size(width: 1920, height: 1080)
        }
    }
}

public struct AudioConfig {
    public let bitrate: Int

    public init(bitrate: Int = 128000) {
        self.bitrate = bitrate
    }
}

public struct VideoConfig {
    public let bitrate: Int
    public let resolution: Resolution
    public let fps: Int

    public init(resolution: Resolution = Resolution.RESOLUTION_720, fps: Int = 30) {
        self.bitrate = VideoConfig.getDefaultBitrate(resolution: resolution)
        self.resolution = resolution
        self.fps = fps
    }

    public init(bitrate: Int, resolution: Resolution = Resolution.RESOLUTION_720, fps: Int = 30) {
        self.bitrate = bitrate
        self.resolution = resolution
        self.fps = fps
    }

    static func getDefaultBitrate(resolution: Resolution) -> Int {
        switch resolution {
            case Resolution.RESOLUTION_240: return 800000
            case Resolution.RESOLUTION_360: return 1000000
            case Resolution.RESOLUTION_480: return 1300000
            case Resolution.RESOLUTION_720: return 2000000
            case Resolution.RESOLUTION_1080: return 3500000
       }
    }
}
