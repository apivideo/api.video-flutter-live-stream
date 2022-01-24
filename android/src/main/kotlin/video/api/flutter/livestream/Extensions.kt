package video.api.flutter.livestream

import video.api.livestream.enums.Resolution
import video.api.livestream.models.AudioConfig
import video.api.livestream.models.VideoConfig

fun Map<String, Any>.toVideoConfig(): VideoConfig {
    return VideoConfig(
        bitrate = this["bitrate"] as Int,
        resolution = (this["resolution"] as String).toResolution(),
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

fun String.toResolution(): Resolution {
    return when (this) {
        "240p" -> Resolution.RESOLUTION_240
        "360p" -> Resolution.RESOLUTION_360
        "480p" -> Resolution.RESOLUTION_480
        "720p" -> Resolution.RESOLUTION_720
        "1080p" -> Resolution.RESOLUTION_1080
        "2160p" -> Resolution.RESOLUTION_2160
        else -> Resolution.RESOLUTION_720
    }
}


