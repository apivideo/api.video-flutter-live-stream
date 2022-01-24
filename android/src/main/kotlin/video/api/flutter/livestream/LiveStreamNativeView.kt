package video.api.flutter.livestream

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.platform.PlatformView
import video.api.livestream.ApiVideoLiveStream
import video.api.livestream.enums.CameraFacingDirection
import video.api.livestream.interfaces.IConnectionChecker
import video.api.livestream.views.ApiVideoView


class LiveStreamNativeView(
    context: Context,
    id: Int,
    messenger: BinaryMessenger,
    creationParams: Map<String, Any>
) :
    PlatformView, IConnectionChecker, MethodCallHandler {
    companion object {
        const val TAG = "LiveStreamNativeView"
    }

    private val glView = ApiVideoView(context)
    private var liveStream =
        ApiVideoLiveStream(
            context = context,
            connectionChecker = this,
            initialAudioConfig = (creationParams["audioParameters"] as Map<String, Any>).toAudioConfig(),
            initialVideoConfig = (creationParams["videoParameters"] as Map<String, Any>).toVideoConfig(),
            apiVideoView = glView
        )
    private var methodChannel = MethodChannel(messenger, "video.api.livestream/controller")

    override fun getView() = glView

    override fun dispose() {
        try {
            stopStreaming()
            stopPreview()
            methodChannel.setMethodCallHandler(null)
        } catch (e: Exception) {
            Log.e(TAG, "Already null")
        }
    }

    init {
        methodChannel.setMethodCallHandler(this)
    }

    override fun onConnectionSuccess() {
        Handler(Looper.getMainLooper()).post {
            methodChannel.invokeMethod("onConnectionSuccess", null)
        }
    }

    override fun onConnectionFailed(reason: String) {
        Handler(Looper.getMainLooper()).post {
            methodChannel.invokeMethod("onConnectionFailed", reason)
        }
    }

    override fun onConnectionStarted(url: String) {
        Log.d(TAG, "onConnectionStarted")
    }

    override fun onDisconnect() {
        Handler(Looper.getMainLooper()).post {
            methodChannel.invokeMethod("onDisconnect", null)
        }
    }

    override fun onAuthError() {
        Log.e(TAG, "Rtmp Auth error")
    }

    override fun onAuthSuccess() {
        Log.d(TAG, "Rtmp Auth success")
    }

    private fun setVideoParameters(map: Map<String, Any>) {
        liveStream.videoConfig = map.toVideoConfig()
    }

    private fun setAudioParameters(map: Map<String, Any>) {
        liveStream.audioConfig = map.toAudioConfig()
    }

    private fun startStreaming(streamKey: String, url: String) {
        liveStream.startStreaming(streamKey, url)
    }

    private fun stopStreaming() {
        liveStream.stopStreaming()
    }

    private fun startPreview() {
        liveStream.startPreview()
    }

    private fun stopPreview() {
        liveStream.stopPreview()
    }

    private fun switchCamera() {
        if (liveStream.camera == CameraFacingDirection.BACK) {
            liveStream.camera = CameraFacingDirection.FRONT
        } else {
            liveStream.camera = CameraFacingDirection.BACK
        }
    }

    private fun toggleMute() {
        liveStream.isMuted = !liveStream.isMuted
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
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
                            startStreaming(streamKey, url)
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("failed_to_start_stream", e.message, null)
                        }
                }
            }
            "stopStreaming" -> stopStreaming()
            "setVideoParameters" -> {
                try {
                    setVideoParameters(call.arguments as Map<String, Any>)
                } catch (e: Exception) {
                    result.error("failed_to_set_video_paramters", e.message, null)
                }
            }
            "setAudioParameters" -> {
                try {
                    setAudioParameters(call.arguments as Map<String, Any>)
                } catch (e: Exception) {
                    result.error("failed_to_set_audio_paramters", e.message, null)
                }
            }
            "switchCamera" -> switchCamera()
            "toggleMute" -> toggleMute()
            "startPreview" -> {
                try {
                    startPreview()
                    result.success(null)
                } catch (e: Exception) {
                    result.error("failed_to_start_preview", e.message, null)
                }
            }
            "stopPreview" -> stopPreview()
        }
    }
}