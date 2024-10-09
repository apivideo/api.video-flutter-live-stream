package video.api.flutter.livestream.manager

import android.content.Context
import io.github.thibaultbee.streampack.ext.rtmp.streamers.CameraRtmpLiveStreamer
import io.github.thibaultbee.streampack.streamers.live.BaseCameraLiveStreamer

class InstanceManager(var context: Context? = null) {
    private var instance: BaseCameraLiveStreamer? = null

    fun getInstance(): BaseCameraLiveStreamer {
        if (instance == null) {
            instance = CameraRtmpLiveStreamer(context!!)
        }
        return instance!!
    }

    fun dispose() {
        instance = null
    }
}