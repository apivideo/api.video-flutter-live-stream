package video.api.flutter.livestream

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.view.TextureRegistry
import video.api.flutter.livestream.generated.LiveStreamFlutterApi
import video.api.flutter.livestream.generated.LiveStreamHostApi
import video.api.flutter.livestream.generated.NativeAudioConfig
import video.api.flutter.livestream.generated.NativeResolution
import video.api.flutter.livestream.generated.NativeVideoConfig
import video.api.flutter.livestream.manager.InstanceManager
import video.api.flutter.livestream.manager.LiveStreamViewManager
import video.api.flutter.livestream.manager.PermissionsManager
import video.api.flutter.livestream.utils.addTrailingSlashIfNeeded
import video.api.flutter.livestream.utils.toAudioConfig
import video.api.flutter.livestream.utils.toNativeResolution
import video.api.flutter.livestream.utils.toVideoConfig

fun LiveStreamHostApiImpl(
    instanceManager: InstanceManager,
    permissionsManager: PermissionsManager,
    textureRegistry: TextureRegistry,
    binaryMessenger: BinaryMessenger,
) = LiveStreamHostApiImpl(
    instanceManager,
    permissionsManager,
    textureRegistry,
    LiveStreamFlutterApi(binaryMessenger)
)

class LiveStreamHostApiImpl(
    private val instanceManager: InstanceManager,
    private val permissionsManager: PermissionsManager,
    private val textureRegistry: TextureRegistry,
    private val liveStreamFlutterApi: LiveStreamFlutterApi,
) : LiveStreamHostApi {
    private var flutterView: LiveStreamViewManager? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun create(): Long {
        flutterView?.dispose()
        instanceManager.dispose()
        flutterView = LiveStreamViewManager(
            instanceManager.getInstance(),
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

    override fun getCameraId(): String {
        return flutterView!!.camera
    }

    override fun setCameraId(cameraId: String, callback: (Result<Unit>) -> Unit) {
        flutterView!!.setCamera(cameraId,
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
