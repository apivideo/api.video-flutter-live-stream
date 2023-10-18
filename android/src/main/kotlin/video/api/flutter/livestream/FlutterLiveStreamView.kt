package video.api.flutter.livestream

import android.Manifest
import android.content.Context
import android.util.Size
import android.view.Surface
import io.flutter.view.TextureRegistry
import io.github.thibaultbee.streampack.data.AudioConfig
import io.github.thibaultbee.streampack.data.VideoConfig
import io.github.thibaultbee.streampack.error.StreamPackError
import io.github.thibaultbee.streampack.ext.rtmp.streamers.CameraRtmpLiveStreamer
import io.github.thibaultbee.streampack.listeners.OnConnectionListener
import io.github.thibaultbee.streampack.listeners.OnErrorListener
import io.github.thibaultbee.streampack.utils.getBackCameraList
import io.github.thibaultbee.streampack.utils.getExternalCameraList
import io.github.thibaultbee.streampack.utils.getFrontCameraList
import io.github.thibaultbee.streampack.utils.isBackCamera
import io.github.thibaultbee.streampack.utils.isExternalCamera
import io.github.thibaultbee.streampack.utils.isFrontCamera
import kotlinx.coroutines.runBlocking

class FlutterLiveStreamView(
    private val context: Context,
    textureRegistry: TextureRegistry,
    private val permissionsManager: PermissionsManager,
    private val onConnectionSucceeded: () -> Unit,
    private val onDisconnected: () -> Unit,
    private val onConnectionFailed: (String) -> Unit,
    private val onGenericError: (Exception) -> Unit,
    private val onVideoSizeChanged: (Size) -> Unit,
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

    var videoConfig = VideoConfig()
        set(value) {
            if (isStreaming) {
                throw UnsupportedOperationException("You have to stop streaming first")
            }

            onVideoSizeChanged(value.resolution)

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

    var audioConfig = AudioConfig()
        set(value) {
            if (isStreaming) {
                throw UnsupportedOperationException("You have to stop streaming first")
            }
            permissionsManager.requestPermission(
                Manifest.permission.RECORD_AUDIO,
                onGranted = {
                    streamer.configure(value)
                },
                onShowPermissionRationale = { onRequiredPermissionLastTime ->
                    /**
                     * Require an AppCompat theme to use MaterialAlertDialogBuilder
                     *
                    context.showDialog(
                        R.string.permission_required,
                        R.string.record_audio_permission_required_message,
                        android.R.string.ok,
                        onPositiveButtonClick = { onRequiredPermissionLastTime() }
                    ) */
                    onGenericError(SecurityException("Missing permission Manifest.permission.RECORD_AUDIO"))
                },
                onDenied = {
                    onGenericError(SecurityException("Missing permission Manifest.permission.RECORD_AUDIO"))
                })
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
        val isConnected = streamer.isConnected
        streamer.stopStream()
        streamer.disconnect()
        if (isConnected) {
            onDisconnected()
        }
        _isStreaming = false
    }

    fun startPreview() {
        permissionsManager.requestPermission(
            Manifest.permission.CAMERA,
            onGranted = {
                streamer.startPreview(getSurface(videoConfig.resolution))
                _isPreviewing = true
            },
            onShowPermissionRationale = { onRequiredPermissionLastTime ->
                /**
                 * Require an AppCompat theme to use MaterialAlertDialogBuilder
                 *
                 * context.showDialog(
                    R.string.permission_required,
                    R.string.camera_permission_required_message,
                    android.R.string.ok,
                    onPositiveButtonClick = { onRequiredPermissionLastTime() }
                )*/
                onGenericError(SecurityException("Missing permission Manifest.permission.CAMERA"))
            },
            onDenied = {
                onGenericError(SecurityException("Missing permission Manifest.permission.CAMERA"))
            })
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
        onConnectionSucceeded()
    }

    override fun onLost(message: String) {
        onDisconnected()
    }

    override fun onFailed(message: String) {
        onConnectionFailed(message)
    }

    override fun onError(error: StreamPackError) {
        _isStreaming = false
        onGenericError(error)
    }
}