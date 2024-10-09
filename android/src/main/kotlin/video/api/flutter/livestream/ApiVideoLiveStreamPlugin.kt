package video.api.flutter.livestream

import android.app.Activity
import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.view.TextureRegistry
import video.api.flutter.livestream.generated.CameraInfoHostApi
import video.api.flutter.livestream.generated.CameraProviderHostApi
import video.api.flutter.livestream.generated.CameraSettingsHostApi
import video.api.flutter.livestream.generated.LiveStreamHostApi
import video.api.flutter.livestream.manager.InstanceManager
import video.api.flutter.livestream.manager.PermissionsManager


/** ApiVideoLiveStreamPlugin */
class ApiVideoLiveStreamPlugin : FlutterPlugin, ActivityAware {
    private var pluginBinding: FlutterPluginBinding? = null
    private var activityBinding: ActivityPluginBinding? = null

    private val instanceManager = InstanceManager()

    private var permissionsManager: PermissionsManager? = null
    private var liveStreamHostApiImpl: LiveStreamHostApiImpl? = null
    private var cameraProviderHostApiImpl: CameraProviderHostApiImpl? = null
    private var cameraInfoHostApi: CameraInfoHostApiImpl? = null
    private var cameraSettingsHostApiImpl: CameraSettingsHostApiImpl? = null

    private fun setUp(
        permissionsManager: PermissionsManager,
        binaryMessenger: BinaryMessenger,
        context: Context,
        textureRegistry: TextureRegistry
    ) {
        instanceManager.context = context

        liveStreamHostApiImpl = LiveStreamHostApiImpl(
            instanceManager,
            permissionsManager,
            textureRegistry,
            binaryMessenger
        ).apply {
            LiveStreamHostApi.setUp(binaryMessenger, this)
        }

        cameraProviderHostApiImpl = CameraProviderHostApiImpl(context).apply {
            CameraProviderHostApi.setUp(binaryMessenger, this)
        }

        cameraInfoHostApi = CameraInfoHostApiImpl(context).apply {
            CameraInfoHostApi.setUp(binaryMessenger, this)
        }

        cameraSettingsHostApiImpl = CameraSettingsHostApiImpl(instanceManager).apply {
            CameraSettingsHostApi.setUp(binaryMessenger, this)
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

        updateContext(pluginBinding!!.applicationContext)
        updateActivity(null)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityBinding = binding
        val activity = binding.activity

        val permissionsManager = requireNotNull(permissionsManager)
        permissionsManager.activity = activity
        binding.addRequestPermissionsResultListener(permissionsManager)

        updateContext(activity)
        updateActivity(activity)
    }

    override fun onDetachedFromActivity() {
        permissionsManager?.let {
            it.activity = null
            activityBinding?.removeRequestPermissionsResultListener(it)
        }

        updateContext(pluginBinding!!.applicationContext)
        updateActivity(null)
        activityBinding = null
    }

    fun updateActivity(activity: Activity?) {

    }

    fun updateContext(context: Context) {
        instanceManager.context = context

        cameraProviderHostApiImpl?.context = context
        cameraInfoHostApi?.context = context
    }
}
