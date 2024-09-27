// Autogenerated from Pigeon (v22.4.0), do not edit directly.
// See also: https://pub.dev/packages/pigeon
@file:Suppress("UNCHECKED_CAST", "ArrayInDataClass")

package video.api.flutter.livestream.generated

import android.util.Log
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MessageCodec
import io.flutter.plugin.common.StandardMessageCodec
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer

private fun wrapResult(result: Any?): List<Any?> {
  return listOf(result)
}

private fun wrapError(exception: Throwable): List<Any?> {
  return if (exception is FlutterError) {
    listOf(
      exception.code,
      exception.message,
      exception.details
    )
  } else {
    listOf(
      exception.javaClass.simpleName,
      exception.toString(),
      "Cause: " + exception.cause + ", Stacktrace: " + Log.getStackTraceString(exception)
    )
  }
}

private fun createConnectionError(channelName: String): FlutterError {
  return FlutterError("channel-error",  "Unable to establish connection on channel: '$channelName'.", "")}

/**
 * Error class for passing custom error details to Flutter via a thrown PlatformException.
 * @property code The error code.
 * @property message The error message.
 * @property details The error details. Must be a datatype supported by the api codec.
 */
class FlutterError (
  val code: String,
  override val message: String? = null,
  val details: Any? = null
) : Throwable()

/** Camera facing direction */
enum class CameraPosition(val raw: Int) {
  /** Front camera */
  FRONT(0),
  /** Back camera */
  BACK(1),
  /** Other camera (external for example) */
  OTHER(2);

  companion object {
    fun ofRaw(raw: Int): CameraPosition? {
      return values().firstOrNull { it.raw == raw }
    }
  }
}

/** Audio channel */
enum class Channel(val raw: Int) {
  /** Stereo (2 channels) */
  STEREO(0),
  /** Mono (1 channel) */
  MONO(1);

  companion object {
    fun ofRaw(raw: Int): Channel? {
      return values().firstOrNull { it.raw == raw }
    }
  }
}

/** Generated class from Pigeon that represents data sent in messages. */
data class NativeResolution (
  val width: Long,
  val height: Long
)
 {
  companion object {
    fun fromList(pigeonVar_list: List<Any?>): NativeResolution {
      val width = pigeonVar_list[0] as Long
      val height = pigeonVar_list[1] as Long
      return NativeResolution(width, height)
    }
  }
  fun toList(): List<Any?> {
    return listOf(
      width,
      height,
    )
  }
}

/**
 * Live streaming audio configuration.
 *
 * Generated class from Pigeon that represents data sent in messages.
 */
data class NativeAudioConfig (
  /** The video bitrate in bps */
  val bitrate: Long,
  /**
   * The number of audio channels
   * Only available on Android
   */
  val channel: Channel,
  /**
   * The sample rate of the audio capture
   * Only available on Android
   * Example: 44100, 48000, 96000
   * For RTMP sample rate, only 11025, 22050, 44100 are supported
   */
  val sampleRate: Long,
  /**
   * Enable the echo cancellation
   * Only available on Android
   */
  val enableEchoCanceler: Boolean,
  /**
   * Enable the noise suppressor
   * Only available on Android
   */
  val enableNoiseSuppressor: Boolean
)
 {
  companion object {
    fun fromList(pigeonVar_list: List<Any?>): NativeAudioConfig {
      val bitrate = pigeonVar_list[0] as Long
      val channel = pigeonVar_list[1] as Channel
      val sampleRate = pigeonVar_list[2] as Long
      val enableEchoCanceler = pigeonVar_list[3] as Boolean
      val enableNoiseSuppressor = pigeonVar_list[4] as Boolean
      return NativeAudioConfig(bitrate, channel, sampleRate, enableEchoCanceler, enableNoiseSuppressor)
    }
  }
  fun toList(): List<Any?> {
    return listOf(
      bitrate,
      channel,
      sampleRate,
      enableEchoCanceler,
      enableNoiseSuppressor,
    )
  }
}

/**
 * Live streaming video configuration.
 *
 * Generated class from Pigeon that represents data sent in messages.
 */
data class NativeVideoConfig (
  /** The video bitrate in bps */
  val bitrate: Long,
  /** The live streaming video resolution */
  val resolution: NativeResolution,
  /** The video frame rate in fps */
  val fps: Long,
  /** GOP (Group of Pictures) duration in seconds */
  val gopDurationInS: Double
)
 {
  companion object {
    fun fromList(pigeonVar_list: List<Any?>): NativeVideoConfig {
      val bitrate = pigeonVar_list[0] as Long
      val resolution = pigeonVar_list[1] as NativeResolution
      val fps = pigeonVar_list[2] as Long
      val gopDurationInS = pigeonVar_list[3] as Double
      return NativeVideoConfig(bitrate, resolution, fps, gopDurationInS)
    }
  }
  fun toList(): List<Any?> {
    return listOf(
      bitrate,
      resolution,
      fps,
      gopDurationInS,
    )
  }
}
private open class GeneratedLiveStreamApiPigeonCodec : StandardMessageCodec() {
  override fun readValueOfType(type: Byte, buffer: ByteBuffer): Any? {
    return when (type) {
      129.toByte() -> {
        return (readValue(buffer) as Long?)?.let {
          CameraPosition.ofRaw(it.toInt())
        }
      }
      130.toByte() -> {
        return (readValue(buffer) as Long?)?.let {
          Channel.ofRaw(it.toInt())
        }
      }
      131.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          NativeResolution.fromList(it)
        }
      }
      132.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          NativeAudioConfig.fromList(it)
        }
      }
      133.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          NativeVideoConfig.fromList(it)
        }
      }
      else -> super.readValueOfType(type, buffer)
    }
  }
  override fun writeValue(stream: ByteArrayOutputStream, value: Any?)   {
    when (value) {
      is CameraPosition -> {
        stream.write(129)
        writeValue(stream, value.raw)
      }
      is Channel -> {
        stream.write(130)
        writeValue(stream, value.raw)
      }
      is NativeResolution -> {
        stream.write(131)
        writeValue(stream, value.toList())
      }
      is NativeAudioConfig -> {
        stream.write(132)
        writeValue(stream, value.toList())
      }
      is NativeVideoConfig -> {
        stream.write(133)
        writeValue(stream, value.toList())
      }
      else -> super.writeValue(stream, value)
    }
  }
}


/** Generated interface from Pigeon that represents a handler of messages from Flutter. */
interface LiveStreamHostApi {
  fun create(): Long
  fun dispose()
  fun setVideoConfig(videoConfig: NativeVideoConfig, callback: (Result<Unit>) -> Unit)
  fun setAudioConfig(audioConfig: NativeAudioConfig, callback: (Result<Unit>) -> Unit)
  fun startStreaming(streamKey: String, url: String)
  fun stopStreaming()
  fun startPreview(callback: (Result<Unit>) -> Unit)
  fun stopPreview()
  fun getIsStreaming(): Boolean
  fun getCameraPosition(): CameraPosition
  fun setCameraPosition(position: CameraPosition, callback: (Result<Unit>) -> Unit)
  fun getIsMuted(): Boolean
  fun setIsMuted(isMuted: Boolean)
  fun getVideoResolution(): NativeResolution?

  companion object {
    /** The codec used by LiveStreamHostApi. */
    val codec: MessageCodec<Any?> by lazy {
      GeneratedLiveStreamApiPigeonCodec()
    }
    /** Sets up an instance of `LiveStreamHostApi` to handle messages through the `binaryMessenger`. */
    @JvmOverloads
    fun setUp(binaryMessenger: BinaryMessenger, api: LiveStreamHostApi?, messageChannelSuffix: String = "") {
      val separatedMessageChannelSuffix = if (messageChannelSuffix.isNotEmpty()) ".$messageChannelSuffix" else ""
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.apivideo_live_stream.LiveStreamHostApi.create$separatedMessageChannelSuffix", codec)
        if (api != null) {
          channel.setMessageHandler { _, reply ->
            val wrapped: List<Any?> = try {
              listOf(api.create())
            } catch (exception: Throwable) {
              wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.apivideo_live_stream.LiveStreamHostApi.dispose$separatedMessageChannelSuffix", codec)
        if (api != null) {
          channel.setMessageHandler { _, reply ->
            val wrapped: List<Any?> = try {
              api.dispose()
              listOf(null)
            } catch (exception: Throwable) {
              wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.apivideo_live_stream.LiveStreamHostApi.setVideoConfig$separatedMessageChannelSuffix", codec)
        if (api != null) {
          channel.setMessageHandler { message, reply ->
            val args = message as List<Any?>
            val videoConfigArg = args[0] as NativeVideoConfig
            api.setVideoConfig(videoConfigArg) { result: Result<Unit> ->
              val error = result.exceptionOrNull()
              if (error != null) {
                reply.reply(wrapError(error))
              } else {
                reply.reply(wrapResult(null))
              }
            }
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.apivideo_live_stream.LiveStreamHostApi.setAudioConfig$separatedMessageChannelSuffix", codec)
        if (api != null) {
          channel.setMessageHandler { message, reply ->
            val args = message as List<Any?>
            val audioConfigArg = args[0] as NativeAudioConfig
            api.setAudioConfig(audioConfigArg) { result: Result<Unit> ->
              val error = result.exceptionOrNull()
              if (error != null) {
                reply.reply(wrapError(error))
              } else {
                reply.reply(wrapResult(null))
              }
            }
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.apivideo_live_stream.LiveStreamHostApi.startStreaming$separatedMessageChannelSuffix", codec)
        if (api != null) {
          channel.setMessageHandler { message, reply ->
            val args = message as List<Any?>
            val streamKeyArg = args[0] as String
            val urlArg = args[1] as String
            val wrapped: List<Any?> = try {
              api.startStreaming(streamKeyArg, urlArg)
              listOf(null)
            } catch (exception: Throwable) {
              wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.apivideo_live_stream.LiveStreamHostApi.stopStreaming$separatedMessageChannelSuffix", codec)
        if (api != null) {
          channel.setMessageHandler { _, reply ->
            val wrapped: List<Any?> = try {
              api.stopStreaming()
              listOf(null)
            } catch (exception: Throwable) {
              wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.apivideo_live_stream.LiveStreamHostApi.startPreview$separatedMessageChannelSuffix", codec)
        if (api != null) {
          channel.setMessageHandler { _, reply ->
            api.startPreview{ result: Result<Unit> ->
              val error = result.exceptionOrNull()
              if (error != null) {
                reply.reply(wrapError(error))
              } else {
                reply.reply(wrapResult(null))
              }
            }
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.apivideo_live_stream.LiveStreamHostApi.stopPreview$separatedMessageChannelSuffix", codec)
        if (api != null) {
          channel.setMessageHandler { _, reply ->
            val wrapped: List<Any?> = try {
              api.stopPreview()
              listOf(null)
            } catch (exception: Throwable) {
              wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.apivideo_live_stream.LiveStreamHostApi.getIsStreaming$separatedMessageChannelSuffix", codec)
        if (api != null) {
          channel.setMessageHandler { _, reply ->
            val wrapped: List<Any?> = try {
              listOf(api.getIsStreaming())
            } catch (exception: Throwable) {
              wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.apivideo_live_stream.LiveStreamHostApi.getCameraPosition$separatedMessageChannelSuffix", codec)
        if (api != null) {
          channel.setMessageHandler { _, reply ->
            val wrapped: List<Any?> = try {
              listOf(api.getCameraPosition())
            } catch (exception: Throwable) {
              wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.apivideo_live_stream.LiveStreamHostApi.setCameraPosition$separatedMessageChannelSuffix", codec)
        if (api != null) {
          channel.setMessageHandler { message, reply ->
            val args = message as List<Any?>
            val positionArg = args[0] as CameraPosition
            api.setCameraPosition(positionArg) { result: Result<Unit> ->
              val error = result.exceptionOrNull()
              if (error != null) {
                reply.reply(wrapError(error))
              } else {
                reply.reply(wrapResult(null))
              }
            }
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.apivideo_live_stream.LiveStreamHostApi.getIsMuted$separatedMessageChannelSuffix", codec)
        if (api != null) {
          channel.setMessageHandler { _, reply ->
            val wrapped: List<Any?> = try {
              listOf(api.getIsMuted())
            } catch (exception: Throwable) {
              wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.apivideo_live_stream.LiveStreamHostApi.setIsMuted$separatedMessageChannelSuffix", codec)
        if (api != null) {
          channel.setMessageHandler { message, reply ->
            val args = message as List<Any?>
            val isMutedArg = args[0] as Boolean
            val wrapped: List<Any?> = try {
              api.setIsMuted(isMutedArg)
              listOf(null)
            } catch (exception: Throwable) {
              wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.apivideo_live_stream.LiveStreamHostApi.getVideoResolution$separatedMessageChannelSuffix", codec)
        if (api != null) {
          channel.setMessageHandler { _, reply ->
            val wrapped: List<Any?> = try {
              listOf(api.getVideoResolution())
            } catch (exception: Throwable) {
              wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
    }
  }
}
/** Generated class from Pigeon that represents Flutter messages that can be called from Kotlin. */
class LiveStreamFlutterApi(private val binaryMessenger: BinaryMessenger, private val messageChannelSuffix: String = "") {
  companion object {
    /** The codec used by LiveStreamFlutterApi. */
    val codec: MessageCodec<Any?> by lazy {
      GeneratedLiveStreamApiPigeonCodec()
    }
  }
  fun onIsConnectedChanged(isConnectedArg: Boolean, callback: (Result<Unit>) -> Unit)
{
    val separatedMessageChannelSuffix = if (messageChannelSuffix.isNotEmpty()) ".$messageChannelSuffix" else ""
    val channelName = "dev.flutter.pigeon.apivideo_live_stream.LiveStreamFlutterApi.onIsConnectedChanged$separatedMessageChannelSuffix"
    val channel = BasicMessageChannel<Any?>(binaryMessenger, channelName, codec)
    channel.send(listOf(isConnectedArg)) {
      if (it is List<*>) {
        if (it.size > 1) {
          callback(Result.failure(FlutterError(it[0] as String, it[1] as String, it[2] as String?)))
        } else {
          callback(Result.success(Unit))
        }
      } else {
        callback(Result.failure(createConnectionError(channelName)))
      } 
    }
  }
  fun onConnectionFailed(messageArg: String, callback: (Result<Unit>) -> Unit)
{
    val separatedMessageChannelSuffix = if (messageChannelSuffix.isNotEmpty()) ".$messageChannelSuffix" else ""
    val channelName = "dev.flutter.pigeon.apivideo_live_stream.LiveStreamFlutterApi.onConnectionFailed$separatedMessageChannelSuffix"
    val channel = BasicMessageChannel<Any?>(binaryMessenger, channelName, codec)
    channel.send(listOf(messageArg)) {
      if (it is List<*>) {
        if (it.size > 1) {
          callback(Result.failure(FlutterError(it[0] as String, it[1] as String, it[2] as String?)))
        } else {
          callback(Result.success(Unit))
        }
      } else {
        callback(Result.failure(createConnectionError(channelName)))
      } 
    }
  }
  fun onVideoSizeChanged(resolutionArg: NativeResolution, callback: (Result<Unit>) -> Unit)
{
    val separatedMessageChannelSuffix = if (messageChannelSuffix.isNotEmpty()) ".$messageChannelSuffix" else ""
    val channelName = "dev.flutter.pigeon.apivideo_live_stream.LiveStreamFlutterApi.onVideoSizeChanged$separatedMessageChannelSuffix"
    val channel = BasicMessageChannel<Any?>(binaryMessenger, channelName, codec)
    channel.send(listOf(resolutionArg)) {
      if (it is List<*>) {
        if (it.size > 1) {
          callback(Result.failure(FlutterError(it[0] as String, it[1] as String, it[2] as String?)))
        } else {
          callback(Result.success(Unit))
        }
      } else {
        callback(Result.failure(createConnectionError(channelName)))
      } 
    }
  }
  fun onError(codeArg: String, messageArg: String, callback: (Result<Unit>) -> Unit)
{
    val separatedMessageChannelSuffix = if (messageChannelSuffix.isNotEmpty()) ".$messageChannelSuffix" else ""
    val channelName = "dev.flutter.pigeon.apivideo_live_stream.LiveStreamFlutterApi.onError$separatedMessageChannelSuffix"
    val channel = BasicMessageChannel<Any?>(binaryMessenger, channelName, codec)
    channel.send(listOf(codeArg, messageArg)) {
      if (it is List<*>) {
        if (it.size > 1) {
          callback(Result.failure(FlutterError(it[0] as String, it[1] as String, it[2] as String?)))
        } else {
          callback(Result.success(Unit))
        }
      } else {
        callback(Result.failure(createConnectionError(channelName)))
      } 
    }
  }
}
