package video.api.flutter.livestream

import android.app.Activity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.view.TextureRegistry
import video.api.flutter.livestream.generated.DeviceOrientationManagerHostApi
import video.api.flutter.livestream.generated.LiveStreamFlutterApi
import video.api.flutter.livestream.generated.LiveStreamHostApi
import video.api.flutter.livestream.manager.PermissionsManager


/** ApiVideoLiveStreamPlugin */
class ApiVideoLiveStreamPlugin : FlutterPlugin, ActivityAware {
    private var pluginBinding: FlutterPluginBinding? = null
    private var activityBinding: ActivityPluginBinding? = null

    private var permissionsManager: PermissionsManager? = null
    private var liveStreamHostApiImpl: LiveStreamHostApiImpl? = null
    private var deviceOrientationManagerHostApiImpl: DeviceOrientationManagerHostApiImpl? = null

    private fun setUp(
        permissionsManager: PermissionsManager,
        binaryMessenger: BinaryMessenger,
        activity: Activity,
        textureRegistry: TextureRegistry
    ) {
        liveStreamHostApiImpl = LiveStreamHostApiImpl(
            activity,
            permissionsManager,
            textureRegistry,
            LiveStreamFlutterApi(binaryMessenger)
        ).apply {
            LiveStreamHostApi.setUp(binaryMessenger, this)
        }
        deviceOrientationManagerHostApiImpl = DeviceOrientationManagerHostApiImpl().apply {
            DeviceOrientationManagerHostApi.setUp(binaryMessenger, this)
        }
    }

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        pluginBinding = binding
        permissionsManager = PermissionsManager(binding.applicationContext)
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        pluginBinding = null
        permissionsManager = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding

        val activity = binding.activity

        val pluginBinding = requireNotNull(pluginBinding)

        val permissionsManager = requireNotNull(permissionsManager)
        permissionsManager.activity = activity
        binding.addRequestPermissionsResultListener(permissionsManager)

        setUp(
            permissionsManager,
            pluginBinding.binaryMessenger,
            activity,
            pluginBinding.textureRegistry
        )

        updateActivity(activity)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        permissionsManager?.let {
            it.activity = null
            activityBinding?.removeRequestPermissionsResultListener(it)
        }

        updateActivity(null)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityBinding = binding

        val permissionsManager = requireNotNull(permissionsManager)
        permissionsManager.activity = binding.activity
        binding.addRequestPermissionsResultListener(permissionsManager)

        updateActivity(binding.activity)
    }

    override fun onDetachedFromActivity() {
        permissionsManager?.let {
            it.activity = null
            activityBinding?.removeRequestPermissionsResultListener(it)
        }

        updateActivity(null)
        activityBinding = null
    }

    fun updateActivity(activity: Activity?) {
        deviceOrientationManagerHostApiImpl?.setActivity(activity)
    }
}
