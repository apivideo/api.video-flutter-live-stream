package video.api.flutter.livestream

import android.app.Activity
import video.api.flutter.livestream.generated.DeviceOrientationManagerHostApi
import video.api.flutter.livestream.manager.DeviceOrientationManager
import video.api.flutter.livestream.utils.toSerializedString

class DeviceOrientationManagerHostApiImpl :
    DeviceOrientationManagerHostApi {
    private val deviceOrientationManager = DeviceOrientationManager()

    fun setActivity(activity: Activity?) {
        deviceOrientationManager.activity = activity
    }

    override fun getUiOrientation(): String {
        return deviceOrientationManager.getUIOrientation().toSerializedString()
    }
}