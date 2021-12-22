package video.api.flutter.livestream

import video.api.livestream.enums.Resolution

object ConfigHelper {
    fun getResolutionFromResolutionString(resolutionString: String): Resolution {
        return when (resolutionString) {
            "240p" -> Resolution.RESOLUTION_240
            "360p" -> Resolution.RESOLUTION_360
            "480p" -> Resolution.RESOLUTION_480
            "720p" -> Resolution.RESOLUTION_720
            "1080p" -> Resolution.RESOLUTION_1080
            "2160p" -> Resolution.RESOLUTION_2160
            else -> Resolution.RESOLUTION_720
        }
    }
}