package video.api.flutter.livestream.utils

import io.flutter.embedding.engine.systemchannels.PlatformChannel

fun PlatformChannel.DeviceOrientation.toSerializedString(): String {
    return when (this) {
        PlatformChannel.DeviceOrientation.PORTRAIT_UP -> "portraitUp"
        PlatformChannel.DeviceOrientation.PORTRAIT_DOWN -> "portraitDown"
        PlatformChannel.DeviceOrientation.LANDSCAPE_LEFT -> "landscapeLeft"
        PlatformChannel.DeviceOrientation.LANDSCAPE_RIGHT -> "landscapeRight"
    }
}

fun String.toDeviceOrientation(): PlatformChannel.DeviceOrientation {
    return when (this) {
        "portraitUp" -> PlatformChannel.DeviceOrientation.PORTRAIT_UP
        "portraitDown" -> PlatformChannel.DeviceOrientation.PORTRAIT_DOWN
        "landscapeLeft" -> PlatformChannel.DeviceOrientation.LANDSCAPE_LEFT
        "landscapeRight" -> PlatformChannel.DeviceOrientation.LANDSCAPE_RIGHT
        else -> throw UnsupportedOperationException("Could not deserialize device orientation: $this")
    }
}