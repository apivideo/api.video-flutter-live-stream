package video.api.flutter.livestream.utils

import android.media.AudioFormat
import android.util.Size
import io.github.thibaultbee.streampack.data.AudioConfig
import io.github.thibaultbee.streampack.data.VideoConfig
import video.api.flutter.livestream.generated.NativeChannel
import video.api.flutter.livestream.generated.NativeAudioConfig
import video.api.flutter.livestream.generated.NativeResolution
import video.api.flutter.livestream.generated.NativeVideoConfig

fun NativeResolution.toSize() = Size(width.toInt(), height.toInt())

fun Size.toNativeResolution() = NativeResolution(width.toLong(), height.toLong())

fun NativeVideoConfig.toVideoConfig() = VideoConfig(
    startBitrate = bitrate.toInt(),
    resolution = resolution.toSize(),
    fps = fps.toInt(),
    gopDuration = gopDurationInS.toFloat()
)

fun NativeChannel.toChannelConfig() = when (this) {
    NativeChannel.MONO -> AudioFormat.CHANNEL_IN_MONO
    NativeChannel.STEREO -> AudioFormat.CHANNEL_IN_STEREO
}

fun NativeAudioConfig.toAudioConfig() = AudioConfig(
    startBitrate = bitrate.toInt(),
    sampleRate = sampleRate.toInt(),
    channelConfig = channel.toChannelConfig(),
    enableEchoCanceler = enableEchoCanceler,
    enableNoiseSuppressor = enableNoiseSuppressor
)