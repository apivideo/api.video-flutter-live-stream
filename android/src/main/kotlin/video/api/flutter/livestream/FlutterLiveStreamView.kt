package video.api.flutter.livestream

import android.Manifest
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Size
import android.view.Surface
import androidx.annotation.RequiresPermission
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.view.TextureRegistry
import io.github.thibaultbee.streampack.data.AudioConfig
import io.github.thibaultbee.streampack.data.VideoConfig
import io.github.thibaultbee.streampack.error.StreamPackError
import io.github.thibaultbee.streampack.ext.rtmp.streamers.CameraRtmpLiveStreamer
import io.github.thibaultbee.streampack.listeners.OnConnectionListener
import io.github.thibaultbee.streampack.listeners.OnErrorListener
import io.github.thibaultbee.streampack.utils.*
import kotlinx.coroutines.runBlocking

class FlutterLiveStreamView(
    private val context: Context,
    textureRegistry: TextureRegistry,
    messenger: BinaryMessenger
) :
    OnConnectionListener, OnErrorListener {
    private val flutterTexture = textureRegistry.createSurfaceTexture()
    val textureId: Long
        get() = flutterTexture.id()

    private val streamer = CameraRtmpLiveStreamer(
        context = context,
        initialOnConnectionListener = this,
        initialOnErrorListener = this
    )

    private var _isPreviewing = false
    private var _isStreaming = false
    val isStreaming: Boolean
        get() = _isStreaming

    private var eventSink: EventChannel.EventSink? = null
    private val eventChannel = EventChannel(messenger, "video.api.livestream/events")

    init {
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink?.endOfStream()
                eventSink = null
            }
        })
    }

    var videoConfig = VideoConfig()
        set(value) {
            if (isStreaming) {
                throw UnsupportedOperationException("You have to stop streaming first")
            }
            eventSink?.success(
                mapOf(
                    "type" to "videoSizeChanged",
                    "width" to value.resolution.width.toDouble(),
                    "height" to value.resolution.height.toDouble() // Dart size fields are in double
                )
            )

            val wasPreviewing = _isPreviewing
            if (wasPreviewing) {
                stopPreview()
            }
            streamer.configure(value)
            field = value
            if (wasPreviewing) {
                startPreview()
            }
        }

    @RequiresPermission(Manifest.permission.RECORD_AUDIO)
    var audioConfig = AudioConfig()
        set(value) {
            if (isStreaming) {
                throw UnsupportedOperationException("You have to stop streaming first")
            }
            streamer.configure(value)
            field = value
        }

    var isMuted: Boolean
        get() = streamer.settings.audio.isMuted
        set(value) {
            streamer.settings.audio.isMuted = value
        }

    var camera: String
        get() = streamer.camera
        set(value) {
            streamer.camera = value
        }

    var cameraPosition: String
        get() = when {
            context.isFrontCamera(streamer.camera) -> "front"
            context.isBackCamera(streamer.camera) -> "back"
            context.isExternalCamera(streamer.camera) -> "other"
            else -> throw IllegalArgumentException("Invalid camera position for camera ${streamer.camera}")
        }
        set(value) {
            val cameraList = when (value) {
                "front" -> context.getFrontCameraList()
                "back" -> context.getBackCameraList()
                "other" -> context.getExternalCameraList()
                else -> throw IllegalArgumentException("Invalid camera position: $value")
            }
            streamer.camera = cameraList[0]
        }

    fun dispose() {
        streamer.stopStream()
        streamer.stopPreview()
        flutterTexture.release()
    }

    fun startStream(url: String) {
        runBlocking {
            streamer.connect(url)
            try {
                streamer.startStream()
                _isStreaming = true
            } catch (e: Exception) {
                streamer.disconnect()
                onLost("Failed to start stream: ${e.message}")
                throw e
            }
        }
    }

    fun stopStream() {
        streamer.stopStream()
        streamer.disconnect()
        _isStreaming = false
    }

    @RequiresPermission(Manifest.permission.CAMERA)
    fun startPreview() {
        streamer.startPreview(getSurface(videoConfig.resolution))
        _isPreviewing = true
    }

    fun stopPreview() {
        streamer.stopPreview()
        _isPreviewing = false
    }

    private fun getSurface(resolution: Size): Surface {
        val surfaceTexture = flutterTexture.surfaceTexture().apply {
            setDefaultBufferSize(
                resolution.width,
                resolution.height
            )
        }
        return Surface(surfaceTexture)
    }


    override fun onSuccess() {
        Handler(Looper.getMainLooper()).post {
            eventSink?.success(mapOf("type" to "connected"))
        }
    }

    override fun onLost(message: String) {
        Handler(Looper.getMainLooper()).post {
            eventSink?.success(mapOf("type" to "disconnected"))
        }
    }

    override fun onFailed(message: String) {
        sendConnectionFailed(message)
    }

    override fun onError(error: StreamPackError) {
        _isStreaming = false
        Handler(Looper.getMainLooper()).post {
            eventSink?.error(error::class.java.name, error.message, error)
        }
    }

    private fun sendConnectionFailed(message: String) {
        Handler(Looper.getMainLooper()).post {
            eventSink?.success(mapOf("type" to "connectionFailed", "message" to message))
        }
    }

    companion object {
        private const val TAG = "FlutterLiveStreamView"
    }
}