package video.api.flutter.livestream

import android.app.Activity
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.util.Size
import android.view.Surface
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import io.flutter.view.TextureRegistry
import io.flutter.view.TextureRegistry.SurfaceTextureEntry
import io.github.thibaultbee.streampack.data.AudioConfig
import io.github.thibaultbee.streampack.data.VideoConfig
import io.github.thibaultbee.streampack.error.StreamPackError
import io.github.thibaultbee.streampack.ext.rtmp.streamers.CameraRtmpLiveStreamer
import io.github.thibaultbee.streampack.listeners.OnConnectionListener
import io.github.thibaultbee.streampack.listeners.OnErrorListener
import io.github.thibaultbee.streampack.utils.getBackCameraList
import io.github.thibaultbee.streampack.utils.getFrontCameraList
import io.github.thibaultbee.streampack.utils.isFrontCamera
import kotlinx.coroutines.runBlocking
import kotlin.reflect.KFunction1

class MethodCallHandlerImpl(
    private val activity: Activity,
    messenger: BinaryMessenger,
    private val cameraPermissions: CameraPermissions,
    private val permissionsRegistry: KFunction1<PluginRegistry.RequestPermissionsResultListener, Unit>,
    private val textureRegistry: TextureRegistry
) :
    MethodChannel.MethodCallHandler, OnConnectionListener, OnErrorListener {
    companion object {
        private const val TAG = "MethodCallHandlerImpl"
    }

    private var flutterTexture: SurfaceTextureEntry? = null

    private var streamer: CameraRtmpLiveStreamer? = null
    private var videoConfig = VideoConfig()

    private var methodChannel =
        MethodChannel(messenger, "video.api.livestream/controller")

    init {
        methodChannel.setMethodCallHandler(this)
    }

    override fun onFailed(message: String) {
        Handler(Looper.getMainLooper()).post {
            methodChannel.invokeMethod("onConnectionFailed", message)
        }
    }

    override fun onLost(message: String) {
        Handler(Looper.getMainLooper()).post {
            methodChannel.invokeMethod("onDisconnect", null)
        }
    }

    override fun onSuccess() {
        Handler(Looper.getMainLooper()).post {
            methodChannel.invokeMethod("onConnectionSuccess", null)
        }
    }

    override fun onError(error: StreamPackError) {
        Log.e(TAG, "Get error", error)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "create" -> {
                cameraPermissions.requestPermissions(
                    activity,
                    permissionsRegistry,
                    true
                ) { errCode, errDesc ->
                    if (errCode == null) {
                        instantiateCamera(call, result)
                    } else {
                        result.error(errCode, errDesc, null)
                    }
                }

            }
            "dispose" -> {
                flutterTexture?.release()
            }
            "startStreaming" -> {
                val streamKey = call.argument<String>("streamKey")
                val url = call.argument<String>("url")
                when {
                    streamKey == null -> result.error(
                        "missing_stream_key",
                        "Stream key is missing",
                        null
                    )
                    url == null -> result.error("missing_rtmp_url", "RTMP URL is missing", null)
                    else ->
                        try {
                            streamer?.let {
                                runBlocking {
                                    it.startStream(url.addTrailingSlashIfNeeded() + streamKey)
                                }
                                result.success(null)
                            } ?: result.error(
                                "missing_live_stream",
                                "Live stream must exist at this point",
                                null
                            )
                        } catch (e: Exception) {
                            result.error("failed_to_start_stream", e.message, null)
                        }
                }
            }
            "stopStreaming" -> streamer?.stopStream()
            "setVideoParameters" -> {
                try {
                    videoConfig = (call.arguments as Map<String, Any>).toVideoConfig()
                    streamer?.configure(videoConfig)
                } catch (e: Exception) {
                    result.error("failed_to_set_video_parameters", e.message, null)
                }
            }
            "setAudioParameters" -> {
                try {
                    val audioConfig = (call.arguments as Map<String, Any>).toAudioConfig()
                    streamer?.configure(audioConfig)
                } catch (e: Exception) {
                    result.error("failed_to_set_audio_parameters", e.message, null)
                }
            }
            "switchCamera" -> streamer?.let { switchCamera(it) }
            "toggleMute" -> streamer?.let { toggleMute(it) }
            "startPreview" -> {
                try {
                    streamer?.let {
                        it.startPreview(getSurface(videoConfig!!.resolution))
                        result.success(null)
                    } ?: result.error(
                        "missing_live_stream",
                        "Live stream must exist at this point",
                        null
                    )
                    result.success(null)
                } catch (e: Exception) {
                    result.error("failed_to_start_preview", e.message, null)
                }
            }
            "stopPreview" -> streamer?.stopPreview()
        }
    }

    fun stopListening() {
        methodChannel.setMethodCallHandler(null)
    }

    private fun instantiateCamera(call: MethodCall, result: MethodChannel.Result) {
        val videoParameters = call.argument<Map<String, Any>>("videoParameters")
        val audioParameters = call.argument<Map<String, Any>>("audioParameters")
        when {
            videoParameters == null -> result.error(
                "missing_video_parameters",
                "Video parameters are missing",
                null
            )
            audioParameters == null -> result.error(
                "missing_audio_parameters",
                "Audio parameters are missing",
                null
            )
            else ->
                try {
                    // Reset preview live stream if needed
                    streamer?.stopStream()
                    streamer?.stopPreview()

                    val audioConfig = audioParameters.toAudioConfig()
                    videoConfig = videoParameters.toVideoConfig()

                    flutterTexture = textureRegistry.createSurfaceTexture()

                    streamer = CameraRtmpLiveStreamer(
                        context = activity.applicationContext,
                        initialOnConnectionListener = this
                    ).apply {
                        configure(audioConfig, videoConfig)
                        startPreview(getSurface(videoConfig!!.resolution))
                    }

                    val reply: MutableMap<String, Any> = HashMap()
                    reply["textureId"] = flutterTexture!!.id()
                    result.success(reply)
                } catch (e: Exception) {
                    result.error("failed_to_create_live_stream", e.message, null)
                }
        }
    }

    private fun getSurface(resolution: Size): Surface {
        val surfaceTexture = flutterTexture!!.surfaceTexture().apply {
            setDefaultBufferSize(
                resolution.width,
                resolution.height
            )
        }
        return Surface(surfaceTexture)
    }

    private fun switchCamera(streamer: CameraRtmpLiveStreamer) {
        val cameraList = if (activity.isFrontCamera(streamer.camera)) {
            activity.getBackCameraList()
        } else {
            activity.getFrontCameraList()
        }
        streamer.camera = cameraList[0]
    }

    private fun toggleMute(streamer: CameraRtmpLiveStreamer) {
        streamer.settings.audio.isMuted = !streamer.settings.audio.isMuted
    }
}
