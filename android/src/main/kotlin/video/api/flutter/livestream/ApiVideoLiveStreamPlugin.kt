package video.api.flutter.livestream

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin

/** ApiVideoLiveStreamPlugin */
class ApiVideoLiveStreamPlugin: FlutterPlugin{
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    flutterPluginBinding
      .platformViewRegistry
      .registerViewFactory("<platform-view-type>", NativeViewFactory(flutterPluginBinding.binaryMessenger))
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }
}
