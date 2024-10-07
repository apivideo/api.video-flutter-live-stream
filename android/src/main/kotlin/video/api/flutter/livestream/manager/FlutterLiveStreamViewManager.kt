package video.api.flutter.livestream.manager

import android.Manifest
import android.content.Context
import android.util.Log
import android.util.Size
import android.view.Surface
import io.flutter.view.TextureRegistry
import io.flutter.view.TextureRegistry.SurfaceProducer
import io.github.thibaultbee.streampack.data.AudioConfig
import io.github.thibaultbee.streampack.data.VideoConfig
import io.github.thibaultbee.streampack.error.StreamPackError
import io.github.thibaultbee.streampack.ext.rtmp.streamers.CameraRtmpLiveStreamer
import io.github.thibaultbee.streampack.listeners.OnConnectionListener
import io.github.thibaultbee.streampack.listeners.OnErrorListener
import kotlinx.coroutines.runBlocking

fun FlutterLiveStreamViewManager(
    context: Context,
    textureRegistry: TextureRegistry,
    permissionsManager: PermissionsManager,
    onConnectionSucceeded: () -> Unit,
    onDisconnected: () -> Unit,
    onConnectionFailed: (String) -> Unit,
    onGenericError: (Exception) -> Unit,
    onVideoSizeChanged: (Size) -> Unit,
) = FlutterLiveStreamViewManager(
    context,
    textureRegistry.createSurfaceProducer(),
    permissionsManager,
    onConnectionSucceeded,
    onDisconnected,
    onConnectionFailed,
    onGenericError,
    onVideoSizeChanged
)

class FlutterLiveStreamViewManager(
    context: Context,
    private val surfaceProducer: SurfaceProducer,
    private val permissionsManager: PermissionsManager,
    private val onConnectionSucceeded: () -> Unit,
    private val onDisconnected: () -> Unit,
    private val onConnectionFailed: (String) -> Unit,
    private val onGenericError: (Exception) -> Unit,
    private val onVideoSizeChanged: (Size) -> Unit,
) :
    OnConnectionListener, OnErrorListener {
    val textureId = surfaceProducer.id()

    private val streamer = CameraRtmpLiveStreamer(
        context = context,
        initialOnConnectionListener = this,
        initialOnErrorListener = this
    )

    private var _isPreviewing = false
    private var _isStreaming = false
    val isStreaming: Boolean
        get() = _isStreaming

    private var _videoConfig: VideoConfig? = null
    val videoConfig: VideoConfig
        get() = _videoConfig!!

    init {
        surfaceProducer.setCallback(object : SurfaceProducer.Callback {
            override fun onSurfaceCreated() {
                Log.i(TAG, "Surface created")
            }

            override fun onSurfaceDestroyed() {
                Log.i(TAG, "Surface destroyed")
                streamer.stopPreview()
            }
        })
    }


    fun setVideoConfig(
        videoConfig: VideoConfig,
        onSuccess: () -> Unit,
        onError: (Exception) -> Unit
    ) {
        if (isStreaming) {
            throw UnsupportedOperationException("You have to stop streaming first")
        }

        onVideoSizeChanged(videoConfig.resolution)

        val wasPreviewing = _isPreviewing
        if (wasPreviewing) {
            stopPreview()
        }
        streamer.configure(videoConfig)
        _videoConfig = videoConfig
        if (wasPreviewing) {
            startPreview(onSuccess, onError)
        } else {
            onSuccess()
        }
    }

    private var _audioConfig: AudioConfig? = null
    val audioConfig: AudioConfig
        get() = _audioConfig!!

    fun setAudioConfig(
        audioConfig: AudioConfig,
        onSuccess: () -> Unit,
        onError: (Exception) -> Unit
    ) {
        if (isStreaming) {
            throw UnsupportedOperationException("You have to stop streaming first")
        }

        permissionsManager.requestPermission(
            Manifest.permission.RECORD_AUDIO,
            onGranted = {
                try {
                    streamer.configure(audioConfig)
                    _audioConfig = audioConfig
                    onSuccess()
                } catch (e: Exception) {
                    onError(e)
                }
            },
            onShowPermissionRationale = { _ ->
                /**
                 * Require an AppCompat theme to use MaterialAlertDialogBuilder
                 *
                context.showDialog(
                R.string.permission_required,
                R.string.record_audio_permission_required_message,
                android.R.string.ok,
                onPositiveButtonClick = { onRequiredPermissionLastTime() }
                ) */
                onError(SecurityException("Missing permission Manifest.permission.RECORD_AUDIO"))
            },
            onDenied = {
                onError(SecurityException("Missing permission Manifest.permission.RECORD_AUDIO"))
            })
    }

    var isMuted: Boolean
        get() = streamer.settings.audio.isMuted
        set(value) {
            streamer.settings.audio.isMuted = value
        }

    val camera: String
        get() = streamer.camera

    fun setCamera(camera: String, onSuccess: () -> Unit, onError: (Exception) -> Unit) {
        permissionsManager.requestPermission(
            Manifest.permission.CAMERA,
            onGranted = {
                try {
                    streamer.camera = camera
                    onSuccess()
                } catch (e: Exception) {
                    onError(e)
                }
            },
            onShowPermissionRationale = { _ ->
                /**
                 * Require an AppCompat theme to use MaterialAlertDialogBuilder
                 *
                 * context.showDialog(
                R.string.permission_required,
                R.string.camera_permission_required_message,
                android.R.string.ok,
                onPositiveButtonClick = { onRequiredPermissionLastTime() }
                )*/
                onError(SecurityException("Missing permission Manifest.permission.CAMERA"))
            },
            onDenied = {
                onError(SecurityException("Missing permission Manifest.permission.CAMERA"))
            })
    }

    var zoomRatio: Float
        get() = streamer.settings.camera.zoom.zoomRatio
        set(value) {
            streamer.settings.camera.zoom.zoomRatio = value
        }

    val maxZoomRatio: Float
        get() = streamer.settings.camera.zoom.availableRatioRange.upper

    fun dispose() {
        stopStream()
        streamer.stopPreview()
        surfaceProducer.release()
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
        runBlocking {
            streamer.stopStream()
            streamer.disconnect()
            if (isConnected) {
                onDisconnected()
            }
            _isStreaming = false
        }
    }

    fun startPreview(onSuccess: () -> Unit, onError: (Exception) -> Unit) {
        permissionsManager.requestPermission(
            Manifest.permission.CAMERA,
            onGranted = {
                if (_videoConfig == null) {
                    onError(IllegalStateException("Video has not been configured!"))
                } else {
                    try {
                        streamer.startPreview(getSurface(videoConfig.resolution))
                        _isPreviewing = true
                        onSuccess()
                    } catch (e: Exception) {
                        onError(e)
                    }
                }
            },
            onShowPermissionRationale = { _ ->
                /**
                 * Require an AppCompat theme to use MaterialAlertDialogBuilder
                 *
                 * context.showDialog(
                R.string.permission_required,
                R.string.camera_permission_required_message,
                android.R.string.ok,
                onPositiveButtonClick = { onRequiredPermissionLastTime() }
                )*/
                onError(SecurityException("Missing permission Manifest.permission.CAMERA"))
            },
            onDenied = {
                onError(SecurityException("Missing permission Manifest.permission.CAMERA"))
            })
    }

    fun stopPreview() {
        streamer.stopPreview()
        _isPreviewing = false
    }

    private fun getSurface(resolution: Size): Surface {
        surfaceProducer.setSize(resolution.width, resolution.height)
        return surfaceProducer.surface
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

    companion object {
        private const val TAG = "FltLiveStreamView"
    }
}