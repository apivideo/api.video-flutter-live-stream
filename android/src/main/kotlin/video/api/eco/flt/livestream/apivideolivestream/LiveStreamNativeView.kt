package video.api.eco.flt.livestream.apivideolivestream

import android.content.Context
import android.graphics.Camera
import android.util.Log
import android.view.View
import com.pedro.encoder.input.video.CameraHelper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import net.ossrs.rtmp.ConnectCheckerRtmp
import video.api.livestream_module.ApiVideoLiveStream
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.lang.Exception

class LiveStreamNativeView(context: Context, id: Int, creationParams: Map<String?, Any?>?, messenger: BinaryMessenger):
    PlatformView, ConnectCheckerRtmp, MethodCallHandler  {

    //private var channel : MethodChannel = MethodChannel(messenger, "apivideolivestream")

    private lateinit var view: LiveStreamView
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
        //channel.setMethodCallHandler(this)
        view = LiveStreamView(context)
        apiVideo = ApiVideoLiveStream(context, this, null, null)
        initMethodChannel(messenger, id)
    }

    private fun initMethodChannel(messenger: BinaryMessenger, viewId: Int){
        methodChannel = MethodChannel(messenger, "apivideolivestream_$viewId")
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
        Log.e("startlive key",livestreamKey)
        apiVideo.startStreaming(livestreamKey, url)
    }
    private fun stopLive(){
        Log.e("stop method","called")
        apiVideo.stopStreaming()
    }
    private fun switchCamera(){
        Log.e("camera switch", apiVideo.videoCamera.toString())
        if(apiVideo.videoCamera === CameraHelper.Facing.BACK){
            apiVideo.videoCamera = CameraHelper.Facing.FRONT
        }else{
            apiVideo.videoCamera = CameraHelper.Facing.BACK
        }
    }

     override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method){
            "setLivestreamKey" -> livestreamKey = call.arguments.toString()
            "startStreaming" -> startLive()
            "stopStreaming" -> stopLive()
            "switchCamera" -> switchCamera()
        }
    }
}