package video.api.eco.flt.livestream.apivideolivestream

import android.content.Context
import android.util.Log
import android.view.View
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import net.ossrs.rtmp.ConnectCheckerRtmp
import video.api.livestream_module.ApiVideoLiveStream
import java.lang.Exception

class LiveStreamNativeView(context: Context, id: Int, creationParams: Map<String?, Any?>?, messenger: BinaryMessenger):
    PlatformView, ConnectCheckerRtmp, MethodChannel.MethodCallHandler  {
    private var channel : MethodChannel = MethodChannel(messenger, "plugin")

    private var view: LiveStreamView
    private var apiVideo: ApiVideoLiveStream
    private var livestreamKey: String = ""
    private var url : String? = null
    private var methodChannel: MethodChannel? = null

    override fun getView(): View {
        return view.findViewById(R.id.opengl_view)
    }
    override fun dispose() {
        try {
            methodChannel?.setMethodCallHandler(null)
        }catch (e: Exception){
            Log.e("MethodCallHandler","Already null")
        }
    }

    init {
        channel.setMethodCallHandler(this)
        view = LiveStreamView(context)
        apiVideo = ApiVideoLiveStream(context, this, view.findViewById(R.id.opengl_view), null)
        initMethodChannel(messenger, id);
    }

    private fun initMethodChannel(messenger: BinaryMessenger, viewId: Int){
        methodChannel = MethodChannel(messenger, "plugin_$viewId")
        methodChannel!!.setMethodCallHandler(this)
    }

    override fun onConnectionSuccessRtmp() {
        Log.i("Rtmp Connection", "success")
    }

    override fun onConnectionFailedRtmp(reason: String?) {
        Log.e("Rtmp Connection", "failed")
    }

    override fun onNewBitrateRtmp(bitrate: Long) {
        Log.i("New rtmp bitrate", "$bitrate")
    }

    override fun onDisconnectRtmp() {
        Log.i("Rtmp connetion", "On disconnect")
    }

    override fun onAuthErrorRtmp() {
        Log.e("Rtmp Auth", "error")
    }

    override fun onAuthSuccessRtmp() {
        Log.i("Rtmp Auth", "success")
    }

    private fun setUrl(newUrl: String?){
        url = if(url != null || url != ""){
            newUrl
        }else{
            null
        }
    }

    private fun startLive(){
        Log.e("startlive method","called")
        apiVideo.startStreaming(livestreamKey, url)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method){
            "setLivestreamKey" -> livestreamKey = call.arguments.toString()
            "startStreaming" -> startLive()
        }
    }
}