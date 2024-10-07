package video.api.flutter.livestream.manager

import android.app.Activity
import android.content.Context
import android.content.res.Configuration
import android.view.Surface
import android.view.WindowManager
import io.flutter.embedding.engine.systemchannels.PlatformChannel

class DeviceOrientationManager {
    var activity: Activity? = null

    private val defaultRotation
        get() = display.rotation

    @Suppress("DEPRECATION")
    private val display
        get() = (activity!!.getSystemService(Context.WINDOW_SERVICE) as WindowManager).defaultDisplay

    fun getUIOrientation(): PlatformChannel.DeviceOrientation {
        val rotation = defaultRotation
        val orientation = activity!!.resources.configuration.orientation

        return when (orientation) {
            Configuration.ORIENTATION_PORTRAIT -> {
                if (rotation == Surface.ROTATION_0 || rotation == Surface.ROTATION_90) {
                    PlatformChannel.DeviceOrientation.PORTRAIT_UP
                } else {
                    PlatformChannel.DeviceOrientation.PORTRAIT_DOWN
                }
            }

            Configuration.ORIENTATION_LANDSCAPE -> {
                if (rotation == Surface.ROTATION_0 || rotation == Surface.ROTATION_90) {
                    PlatformChannel.DeviceOrientation.LANDSCAPE_LEFT
                } else {
                    PlatformChannel.DeviceOrientation.LANDSCAPE_RIGHT
                }
            }

            else -> {
                PlatformChannel.DeviceOrientation.PORTRAIT_UP
            }
        }
    }
}