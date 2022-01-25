package video.api.flutter.livestream

import android.util.Size
import io.github.thibaultbee.streampack.data.AudioConfig
import io.github.thibaultbee.streampack.data.VideoConfig


fun Map<String, Any>.toVideoConfig(): VideoConfig {
    return VideoConfig(
        startBitrate = this["bitrate"] as Int,
        resolution = (this["resolution"] as String).toResolution(),
        fps = this["fps"] as Int
    )
}

fun Map<String, Any>.toAudioConfig(): AudioConfig {
    return AudioConfig(
        startBitrate = this["bitrate"] as Int,
        sampleRate = this["sampleRate"] as Int,
        channelConfig = AudioConfig.getChannelConfig(
            if (this["channel"] == "stereo") {
                2
            } else {
                1
            }
        ),
        enableNoiseSuppressor = this["enableNoiseSuppressor"] as Boolean,
        enableEchoCanceler = this["enableEchoCanceler"] as Boolean
    )
}

fun String.toResolution(): Size {
    return when (this) {
        "240p" -> Size(352, 240)
        "360p" -> Size(640, 360)
        "480p" -> Size(858, 480)
        "720p" -> Size(1280, 720)
        "1080p" -> Size(1920, 1080)
        "2160p" -> Size(4096, 2160)
        else -> throw IllegalArgumentException("Unknown resolution: $this")
    }
}

/**
 * Add a slash at the end of a [String] only if it is missing.
 *
 * @return the given string with a trailing slash.
 */
fun String.addTrailingSlashIfNeeded(): String {
    return if (this.endsWith("/")) this else "$this/"
}


