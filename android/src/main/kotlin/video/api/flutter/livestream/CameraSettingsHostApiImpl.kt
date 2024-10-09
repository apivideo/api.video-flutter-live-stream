package video.api.flutter.livestream

import io.github.thibaultbee.streampack.utils.CameraSettings
import video.api.flutter.livestream.generated.CameraSettingsHostApi
import video.api.flutter.livestream.manager.InstanceManager

class CameraSettingsHostApiImpl(
    private val instanceManager: InstanceManager
) :
    CameraSettingsHostApi {
    private val settings: CameraSettings
        get() = instanceManager.getInstance().settings.camera

    override fun setZoomRatio(zoomRatio: Double) {
        settings.zoom.zoomRatio = zoomRatio.toFloat()
    }

    override fun getZoomRatio(): Double {
        return settings.zoom.zoomRatio.toDouble()
    }
}
