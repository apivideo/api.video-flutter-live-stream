package video.api.flutter.livestream

import video.api.livestream.models.AudioConfig
import video.api.livestream.models.VideoConfig

fun Map<String, Any>.toVideoConfig(): VideoConfig {
    return VideoConfig(
        bitrate = this["bitrate"] as Int,
        resolution = ConfigHelper.getResolutionFromResolutionString(this["resolution"] as String),
        fps = this["fps"] as Int
    )
}

fun Map<String, Any>.toAudioConfig(): AudioConfig {
    return AudioConfig(
        bitrate = this["bitrate"] as Int,
        sampleRate = this["sampleRate"] as Int,
        stereo = this["channel"] == "stereo",
        noiseSuppressor = this["enableNoiseSuppressor"] as Boolean,
        echoCanceler = this["enableEchoCanceler"] as Boolean
    )
}


