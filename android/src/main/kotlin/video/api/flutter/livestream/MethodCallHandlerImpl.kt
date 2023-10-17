package video.api.flutter.livestream

import android.Manifest
import android.app.Activity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import io.flutter.view.TextureRegistry
import kotlin.reflect.KFunction1

class MethodCallHandlerImpl(
    private val activity: Activity,
    private val messenger: BinaryMessenger,
    private val permissionsRegistry: KFunction1<PluginRegistry.RequestPermissionsResultListener, Unit>,
    private val textureRegistry: TextureRegistry
) : MethodChannel.MethodCallHandler {
    private val audioCameraPermissionsManager =
        PermissionsManager(listOf(Manifest.permission.RECORD_AUDIO, Manifest.permission.CAMERA))
    private val audioPermissionsManager =
        PermissionsManager(listOf(Manifest.permission.RECORD_AUDIO))
    private val cameraPermissionsManager = PermissionsManager(listOf(Manifest.permission.CAMERA))

    private val methodChannel = MethodChannel(messenger, "video.api.livestream/controller")
    private var flutterView: FlutterLiveStreamView? = null

    init {
        methodChannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "create" -> {
                try {
                    ensurePermissions(audioCameraPermissionsManager, result) {
                        flutterView?.dispose()
                        flutterView = FlutterLiveStreamView(
                            activity.applicationContext, textureRegistry, messenger
                        )
                        result.success(mapOf("textureId" to flutterView!!.textureId))
                    }
                } catch (e: Exception) {
                    result.error("failed_to_create_live_stream", e.message, null)
                }
            }

            "dispose" -> {
                flutterView!!.dispose()
                flutterView = null
            }

            "setVideoConfig" -> {
                try {
                    ensurePermissions(cameraPermissionsManager, result) {
                        val videoConfig = (call.arguments as Map<String, Any>).toVideoConfig()
                        flutterView!!.videoConfig = videoConfig
                        result.success(null)
                    }
                } catch (e: Exception) {
                    result.error("failed_to_set_video_config", e.message, null)
                }
            }

            "setAudioConfig" -> {
                try {
                    ensurePermissions(audioPermissionsManager, result) {
                        val audioConfig = (call.arguments as Map<String, Any>).toAudioConfig()
                        flutterView!!.audioConfig = audioConfig
                        result.success(null)
                    }
                } catch (e: Exception) {
                    result.error("failed_to_set_audio_config", e.message, null)
                }
            }

            "startPreview" -> {
                try {
                    ensurePermissions(cameraPermissionsManager, result) {
                        flutterView!!.startPreview()
                        result.success(null)
                    }
                } catch (e: Exception) {
                    result.error("failed_to_start_preview", e.message, null)
                }
            }

            "stopPreview" -> {
                flutterView!!.stopPreview()
                result.success(null)
            }

            "startStreaming" -> {
                val streamKey = call.argument<String>("streamKey")
                val url = call.argument<String>("url")
                when {
                    streamKey == null -> result.error(
                        "missing_stream_key", "Stream key is missing", null
                    )

                    streamKey.isEmpty() -> result.error(
                        "empty_stream_key", "Stream key is empty", null
                    )

                    url == null -> result.error(
                        "missing_rtmp_url",
                        "RTMP URL is missing",
                        null
                    )

                    url.isEmpty() -> result.error("empty_rtmp_url", "RTMP URL is empty", null)

                    else -> ensurePermissions(audioCameraPermissionsManager, result) {
                        try {
                            flutterView!!.startStream(url.addTrailingSlashIfNeeded() + streamKey)
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("failed_to_start_stream", e.message, null)
                        }
                    }
                }
            }

            "stopStreaming" -> {
                flutterView!!.stopStream()
                result.success(null)
            }

            "getIsStreaming" -> result.success(mapOf("isStreaming" to flutterView!!.isStreaming))
            "getCameraPosition" -> {
                try {
                    result.success(mapOf("position" to flutterView!!.cameraPosition))
                } catch (e: Exception) {
                    result.error("failed_to_get_camera_position", e.message, null)
                }
            }

            "setCameraPosition" -> {
                val cameraPosition = try {
                    ((call.arguments as Map<*, *>)["position"] as String)
                } catch (e: Exception) {
                    result.error("invalid_parameter", "Invalid camera position", e)
                    return
                }
                flutterView!!.cameraPosition = cameraPosition
                result.success(null)
            }

            "getIsMuted" -> {
                result.success(mapOf("isMuted" to flutterView!!.isMuted))
            }

            "setIsMuted" -> {
                val isMuted = try {
                    ((call.arguments as Map<*, *>)["isMuted"] as Boolean)
                } catch (e: Exception) {
                    result.error("invalid_parameter", "Invalid isMuted", e)
                    return
                }
                flutterView!!.isMuted = isMuted
                result.success(null)
            }

            "getVideoSize" -> {
                val videoSize = flutterView!!.videoConfig.resolution
                result.success(
                    mapOf(
                        "width" to videoSize.width.toDouble(),
                        "height" to videoSize.height.toDouble()
                    )
                )
            }

            else -> result.notImplemented()
        }
    }

    private fun ensurePermissions(
        permissionsManager: PermissionsManager,
        result: MethodChannel.Result,
        onPermissionGranted: () -> Unit
    ) {
        permissionsManager.requestPermissions(
            activity,
            permissionsRegistry,
        ) { errCode, errDesc ->
            if (errCode == null) {
                onPermissionGranted()
            } else {
                result.error(errCode, errDesc, null)
            }
        }
    }

    fun dispose() {
        methodChannel.setMethodCallHandler(null)
    }

    companion object {
        private const val TAG = "MethodCallHandlerImpl"
    }
}
