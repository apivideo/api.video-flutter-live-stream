package video.api.eco.flt.livestream.apivideolivestream

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class NativeViewFactory(private val messenger: BinaryMessenger): PlatformViewFactory(
    StandardMessageCodec.INSTANCE) {
    private lateinit var mess : BinaryMessenger

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as Map<String?, Any?>?
        this.mess = messenger
        return LiveStreamNativeView(context, viewId, this.mess)
    }
}