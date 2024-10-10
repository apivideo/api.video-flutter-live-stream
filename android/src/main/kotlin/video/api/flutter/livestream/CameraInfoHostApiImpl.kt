package video.api.flutter.livestream

import android.content.Context
import android.hardware.camera2.CameraCharacteristics
import android.os.Build
import android.util.Range
import io.github.thibaultbee.streampack.utils.Zoom.Companion.DEFAULT_ZOOM_RATIO
import io.github.thibaultbee.streampack.utils.getCameraCharacteristics
import io.github.thibaultbee.streampack.utils.getScalerMaxZoom
import io.github.thibaultbee.streampack.utils.getZoomRatioRange
import io.github.thibaultbee.streampack.utils.isBackCamera
import io.github.thibaultbee.streampack.utils.isExternalCamera
import io.github.thibaultbee.streampack.utils.isFrontCamera
import video.api.flutter.livestream.generated.CameraInfoHostApi
import video.api.flutter.livestream.generated.NativeCameraLensDirection

class CameraInfoHostApiImpl(
    var context: Context
) : CameraInfoHostApi {
    override fun getSensorRotationDegrees(cameraId: String): Long {
        val characteristics = context.getCameraCharacteristics(cameraId)
        return (characteristics.get(CameraCharacteristics.SENSOR_ORIENTATION) ?: 0).toLong()
    }

    override fun getLensDirection(cameraId: String): NativeCameraLensDirection {
        return when {
            context.isFrontCamera(cameraId) -> NativeCameraLensDirection.FRONT
            context.isBackCamera(cameraId) -> NativeCameraLensDirection.BACK
            context.isExternalCamera(cameraId) -> NativeCameraLensDirection.OTHER
            else -> throw IllegalArgumentException("Invalid camera position for camera $cameraId")
        }
    }

    private fun getZoomRange(cameraId: String): Range<Float> {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            context.getZoomRatioRange(cameraId)!!
        } else {
            Range(
                DEFAULT_ZOOM_RATIO,
                context.getScalerMaxZoom(cameraId)
            )
        }
    }

    override fun getMinZoomRatio(cameraId: String) = getZoomRange(cameraId).lower.toDouble()

    override fun getMaxZoomRatio(cameraId: String) =
        getZoomRange(cameraId).upper.toDouble()
}
