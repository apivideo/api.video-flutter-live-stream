package video.api.flutter.livestream

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.view.TextureRegistry
import io.github.thibaultbee.streampack.utils.backCameraList
import io.github.thibaultbee.streampack.utils.externalCameraList
import io.github.thibaultbee.streampack.utils.frontCameraList
import io.github.thibaultbee.streampack.utils.isBackCamera
import io.github.thibaultbee.streampack.utils.isExternalCamera
import io.github.thibaultbee.streampack.utils.isFrontCamera
import video.api.flutter.livestream.generated.CameraPosition
import video.api.flutter.livestream.generated.LiveStreamFlutterApi
import video.api.flutter.livestream.generated.LiveStreamHostApi
import video.api.flutter.livestream.generated.NativeAudioConfig
import video.api.flutter.livestream.generated.NativeResolution
import video.api.flutter.livestream.generated.NativeVideoConfig
import video.api.flutter.livestream.utils.addTrailingSlashIfNeeded
import video.api.flutter.livestream.utils.toAudioConfig
import video.api.flutter.livestream.utils.toNativeResolution
import video.api.flutter.livestream.utils.toVideoConfig

fun LiveStreamHostApiImpl(
    context: Context,
    permissionsManager: PermissionsManager,
    textureRegistry: TextureRegistry,
    binaryMessenger: BinaryMessenger,
) = LiveStreamHostApiImpl(
    context,
    permissionsManager,
    textureRegistry,
    LiveStreamFlutterApi(binaryMessenger)
)

class LiveStreamHostApiImpl(
    private val context: Context,
    private val permissionsManager: PermissionsManager,
    private val textureRegistry: TextureRegistry,
    private val liveStreamFlutterApi: LiveStreamFlutterApi,
) : LiveStreamHostApi {
    private var flutterView: FlutterLiveStreamView? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun create(): Long {
        flutterView?.dispose()
        flutterView = FlutterLiveStreamView(
            context,
            textureRegistry,
            permissionsManager,
            { executeOnMain { liveStreamFlutterApi.onIsConnectedChanged(true) {} } },
            { executeOnMain { liveStreamFlutterApi.onIsConnectedChanged(false) {} } },
            { executeOnMain { liveStreamFlutterApi.onConnectionFailed(it) {} } },
            {
                executeOnMain {
                    liveStreamFlutterApi.onError(
                        "native-error",
                        it.localizedMessage ?: "Unknown error $it"
                    ) {}
                }
            },
            { executeOnMain { liveStreamFlutterApi.onVideoSizeChanged(it.toNativeResolution()) {} } }
        )
        return flutterView!!.textureId
    }

    override fun dispose() {
        flutterView?.dispose()
        flutterView = null
    }

    override fun setVideoConfig(videoConfig: NativeVideoConfig, callback: (Result<Unit>) -> Unit) {
        flutterView!!.setVideoConfig(
            videoConfig.toVideoConfig(),
            { callback(Result.success(Unit)) },
            { callback(Result.failure(it)) })
    }

    override fun setAudioConfig(audioConfig: NativeAudioConfig, callback: (Result<Unit>) -> Unit) {
        flutterView!!.setAudioConfig(
            audioConfig.toAudioConfig(),
            { callback(Result.success(Unit)) },
            { callback(Result.failure(it)) })
    }

    override fun startStreaming(streamKey: String, url: String) {
        flutterView!!.startStream(url.addTrailingSlashIfNeeded() + streamKey)
    }

    override fun stopStreaming() {
        flutterView?.stopStream()
    }

    override fun startPreview(callback: (Result<Unit>) -> Unit) {
        flutterView!!.startPreview(
            { callback(Result.success(Unit)) },
            { callback(Result.failure(it)) })
    }

    override fun stopPreview() {
        flutterView?.stopPreview()
    }

    override fun getIsStreaming(): Boolean {
        return flutterView!!.isStreaming
    }

    override fun getCameraPosition(): CameraPosition {
        val camera = flutterView!!.camera
        return when {
            context.isFrontCamera(camera) -> CameraPosition.FRONT
            context.isBackCamera(camera) -> CameraPosition.BACK
            context.isExternalCamera(camera) -> CameraPosition.OTHER
            else -> throw IllegalArgumentException("Invalid camera position for camera $camera")
        }
    }

    override fun setCameraPosition(position: CameraPosition, callback: (Result<Unit>) -> Unit) {
        val cameraList = when (position) {
            CameraPosition.FRONT -> context.frontCameraList
            CameraPosition.BACK -> context.backCameraList
            CameraPosition.OTHER -> context.externalCameraList
        }
        flutterView!!.setCamera(cameraList.first(),
            { callback(Result.success(Unit)) },
            { callback(Result.failure(it)) })
    }

    override fun getIsMuted(): Boolean {
        return flutterView!!.isMuted
    }

    override fun setIsMuted(isMuted: Boolean) {
        flutterView!!.isMuted = isMuted
    }

    override fun getVideoResolution(): NativeResolution {
        return flutterView!!.videoConfig.resolution.toNativeResolution()
    }

    private fun executeOnMain(block: () -> Unit) {
        mainHandler.post {
            block()
        }
    }
}
