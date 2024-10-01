import ApiVideoLiveStream

extension NativeResolution {
    func toCGSize() -> CGSize {
        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }
}

extension CGSize {
    func toNativeResolution() -> NativeResolution {
        return NativeResolution(width: Int64(width), height: Int64(height))
    }
}

extension NativeVideoConfig {
    func toVideoConfig() -> VideoConfig {
        return VideoConfig(bitrate: Int(bitrate), resolution: resolution.toCGSize(), fps: Float64(fps), gopDuration: gopDurationInS)
    }
}

extension NativeAudioConfig {
    func toAudioConfig() -> AudioConfig {
        return AudioConfig(bitrate: Int(bitrate))
    }
}
