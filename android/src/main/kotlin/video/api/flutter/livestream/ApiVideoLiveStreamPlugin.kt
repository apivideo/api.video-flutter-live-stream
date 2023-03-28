package video.api.flutter.livestream

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** ApiVideoLiveStreamPlugin */
class ApiVideoLiveStreamPlugin : FlutterPlugin, ActivityAware {
    private var flutterPluginBinding: FlutterPluginBinding? = null
    private var methodCallHandlerImpl: MethodCallHandlerImpl? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPluginBinding) {
        this.flutterPluginBinding = flutterPluginBinding
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        this.flutterPluginBinding = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        methodCallHandlerImpl = MethodCallHandlerImpl(
            binding.activity,
            flutterPluginBinding!!.binaryMessenger,
            binding::addRequestPermissionsResultListener,
            flutterPluginBinding!!.textureRegistry
        )
    }

    override fun onDetachedFromActivity() {
        methodCallHandlerImpl?.dispose()
        methodCallHandlerImpl = null
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }
}
