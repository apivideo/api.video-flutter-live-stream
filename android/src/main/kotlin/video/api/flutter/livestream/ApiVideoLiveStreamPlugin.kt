package video.api.flutter.livestream

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** ApiVideoLiveStreamPlugin */
class ApiVideoLiveStreamPlugin : FlutterPlugin, ActivityAware {
    private var permissionsManager: PermissionsManager? = null
    private var methodCallHandlerImpl: MethodCallHandlerImpl? = null

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        permissionsManager = PermissionsManager(binding.applicationContext).apply {
            methodCallHandlerImpl = MethodCallHandlerImpl(
                binding.applicationContext,
                binding.binaryMessenger,
                this,
                binding.textureRegistry
            ).apply {
                startListening()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        methodCallHandlerImpl?.stopListening()
        methodCallHandlerImpl = null
        permissionsManager = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        val activity = binding.activity
        permissionsManager?.let {
            it.activity = activity
            binding.addRequestPermissionsResultListener(it)
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        permissionsManager?.activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        permissionsManager?.let {
            it.activity = null
            binding.addRequestPermissionsResultListener(it)
        }
    }

    override fun onDetachedFromActivity() {
        permissionsManager?.activity = null
    }
}
