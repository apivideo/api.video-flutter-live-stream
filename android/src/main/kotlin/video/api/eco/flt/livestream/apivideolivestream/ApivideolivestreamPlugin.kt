package video.api.eco.flt.livestream.apivideolivestream

import android.util.Log
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** ApivideolivestreamPlugin */
class ApivideolivestreamPlugin: FlutterPlugin{
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    //channel = MethodChannel(flutterPluginBinding.binaryMessenger, "apivideolivestream")
    //channel.setMethodCallHandler(this)
    flutterPluginBinding
      .platformViewRegistry
      .registerViewFactory("<platform-view-type>", NativeViewFactory(flutterPluginBinding.binaryMessenger))
  }


  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
/*
    channel.setMethodCallHandler(null)
*/
  }
}
