package video.api.eco.flt.livestream.apivideolivestream

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import com.pedro.encoder.input.video.CameraHelper
import com.pedro.rtplibrary.view.OpenGlView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import net.ossrs.rtmp.ConnectCheckerRtmp
import video.api.livestream_module.ApiVideoLiveStream
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import org.json.JSONObject
import video.api.livestream_module.Resolution
import java.lang.Exception

private fun getResolutionFromResolutionString(resolutionString: String?): Resolution {
    return when (resolutionString) {
        "240p" -> Resolution.RESOLUTION_240
        "360p" -> Resolution.RESOLUTION_360
        "480p" -> Resolution.RESOLUTION_480
        "720p" -> Resolution.RESOLUTION_720
        "1080p" -> Resolution.RESOLUTION_1080
        "2160p" -> Resolution.RESOLUTION_2160
        "240p" -> Resolution.RESOLUTION_240
        else -> Resolution.RESOLUTION_720
    }
}
private fun getFacingFromCameraString(resolutionString: String?): CameraHelper.Facing {
    return when (resolutionString) {
        "front" -> CameraHelper.Facing.FRONT
        "back" -> CameraHelper.Facing.BACK
        else -> CameraHelper.Facing.BACK
    }
}

class LiveStreamNativeView(context: Context, id: Int, creationParams: Map<String?, Any?>?, messenger: BinaryMessenger):
    PlatformView, ConnectCheckerRtmp, MethodCallHandler  {

    //private var channel : MethodChannel = MethodChannel(messenger, "apivideolivestream")

    private val glView = OpenGlView(context)
    private var apiVideo: ApiVideoLiveStream
    private var liveStreamKey: String = ""
    private var rtmpServerUrl : String? = null
    private var methodChannel: MethodChannel? = null


    override fun getView() = glView

    override fun dispose() {
        try {
            methodChannel?.setMethodCallHandler(null)
        }catch (e: Exception){
            Log.e("MethodCallHandler","Already null")
        }
    }

    init {
        //channel.setMethodCallHandler(this)
        apiVideo = ApiVideoLiveStream(context, this, getView(), null)
        initMethodChannel(messenger, id)
    }

    private fun initMethodChannel(messenger: BinaryMessenger, viewId: Int){
        methodChannel = MethodChannel(messenger, "apivideolivestream_$viewId")
        methodChannel!!.setMethodCallHandler(this)
    }

    private fun setLiveStreamKey(newLiveStreamKey: String) {
        if (newLiveStreamKey == liveStreamKey) return
        liveStreamKey = newLiveStreamKey
    }

    private fun setRtmpServerUrl(newRtmpServerUrl: String) {
        if (newRtmpServerUrl == rtmpServerUrl) return
        rtmpServerUrl = newRtmpServerUrl
    }

    private fun setVideoFps(newVideoFps: Double) {
        if (newVideoFps.toInt() == apiVideo.videoFps) return
        apiVideo.videoFps = newVideoFps.toInt()
    }

    private fun setVideoBitrate(newVideoBitrate: Double) {
        if (newVideoBitrate.toInt() == apiVideo.videoBitrate) return
        apiVideo.videoBitrate = newVideoBitrate.toInt()
    }

    private fun setVideoResolution(newVideoResolutionString: String) {
        val newVideoResolution = getResolutionFromResolutionString(newVideoResolutionString)
        if (newVideoResolution == apiVideo.videoResolution) return
        apiVideo.videoResolution = newVideoResolution
    }

    private fun setVideoCamera(newVideoCameraString: String) {
        val newVideoCamera = getFacingFromCameraString(newVideoCameraString)
        if (newVideoCamera == apiVideo.videoCamera) return
        apiVideo.videoCamera = newVideoCamera
    }

    private fun setAudioMuted(newAudioMuted: Boolean) {
        if (newAudioMuted == apiVideo.audioMuted) return
        apiVideo.audioMuted = newAudioMuted
    }

    private fun setAudioBitrate(newAudioBitrate: Double) {
        if (newAudioBitrate.toInt() == apiVideo.audioBitrate) return
        apiVideo.audioBitrate = newAudioBitrate.toInt()
    }


    override fun onConnectionSuccessRtmp() {
        Log.i("Rtmp Connection", "success")
        Handler(Looper.getMainLooper()).post {
            methodChannel!!.invokeMethod("onConnectionSuccess", null)
        }

    }

    override fun onConnectionFailedRtmp(reason: String?) {
        Log.e("Rtmp Connection", "failed")
        Handler(Looper.getMainLooper()).post {
            methodChannel!!.invokeMethod("onConnectionError", reason)
        }

    }

    override fun onNewBitrateRtmp(bitrate: Long) {
        Log.i("New rtmp bitrate", "$bitrate")
    }

    override fun onDisconnectRtmp() {
        Log.i("Rtmp connetion", "On disconnect")
        Handler(Looper.getMainLooper()).post {
            methodChannel!!.invokeMethod("onDeconnection", null)
        }

    }

    override fun onAuthErrorRtmp() {
        Log.e("Rtmp Auth", "error")
    }

    override fun onAuthSuccessRtmp() {
        Log.i("Rtmp Auth", "success")
    }

    private fun setUrl(newUrl: String?){
        rtmpServerUrl = if(rtmpServerUrl != null || rtmpServerUrl != ""){
            newUrl
        }else{
            null
        }
    }

    private fun setParam(){
        Log.e("IN SET PARAM", "8888")
        Handler(Looper.getMainLooper()).post{
            methodChannel!!.invokeMethod("setParam",null)
        }
    }

    private fun startLive(){
        Log.e("startlive method","called")
        Log.e("startlive key",liveStreamKey)
        apiVideo.startStreaming(liveStreamKey, rtmpServerUrl)
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

    var mResult: MethodChannel.Result? = null
     override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method){
//            "setLivestreamKey" -> livestreamKey = call.arguments.toString()
            "setLivestreamKey" -> setLiveStreamKey(call.arguments.toString())
            "startStreaming" -> {
                Log.e("Call START STREAMING", "True")
                //setParam()
                startLive()
                mResult = result
            }
            "setParam" -> {
                var obj = JSONObject(call.arguments.toString())
                setLiveStreamKey(obj.getString("liveStreamKey").toString())
                setRtmpServerUrl(obj.getString("rtmpServerUrl").toString())
                setVideoFps(obj.getString("videoFps").toDouble())
                setVideoResolution(obj.getString("videoResolution").toString())
                setVideoBitrate(obj.getString("videoBitrate").toDouble())
                setVideoCamera(obj.getString("videoCamera").toString())
                setAudioMuted(obj.getString("audioMuted").toBoolean())
                setAudioBitrate(obj.getString("audioBitrate").toDouble())
                Log.e("PARAMETER ====> ", liveStreamKey)
            }
            "stopStreaming" -> stopLive()
            "switchCamera" -> switchCamera()
        }
    }
}