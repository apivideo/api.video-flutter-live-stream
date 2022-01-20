import Flutter
import UIKit
import LiveStreamIos
import AVFoundation
import Network

public class SwiftApiVideoLiveStreamPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "video.api.livestream/controller", binaryMessenger: registrar.messenger())
        
        let factory = LiveStreamViewFactory(messenger: registrar.messenger(), channel: channel)
        registrar.register(factory, withId: "<platform-view-type>")
        
        let instance = SwiftApiVideoLiveStreamPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result("iOS " + UIDevice.current.systemVersion)
    }
}

class LiveStreamViewFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger
    private let channel: FlutterMethodChannel
    
    init(messenger: FlutterBinaryMessenger, channel: FlutterMethodChannel) {
        self.messenger = messenger
        self.channel = channel
        super.init()
    }
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return LiveStreamNativeView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger,
            channel: channel
        )
    }
}

class LiveStreamNativeView: NSObject, FlutterPlatformView {
    private let liveStreamView: LiveStreamView
    private let channel: FlutterMethodChannel
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?,
        channel: FlutterMethodChannel
    ) {
        liveStreamView = LiveStreamView(frame: frame, channel: channel)
        self.channel = channel
        super.init()
    }
    
    func view() -> UIView {
        return liveStreamView
    }
    
    func handlerMethodCall(_ call: FlutterMethodCall, _ result: FlutterResult)  {
        switch call.method {
        case "startStreaming":
            if let args = call.arguments as? Dictionary<String, Any> {
                 let streamKey = args["streamKey"] as? String
                 let url = args["url"] as? String
                 if (streamKey == nil) {
                    result(FlutterError.init(code: "missing_stream_key", message: "Stream key is missing", details: nil))
                 } else if (url == nil) {
                    result(FlutterError.init(code: "missing_rtmp_url", message:  "RTMP URL is missing", details: nil))
                 } else {
                    liveStreamView.startStreaming(streamKey: streamKey!, url: url!)
                 }
            }
            break
        case "stopStreaming":
            liveStreamView.stopStreaming()
            break
        case "switchCamera":
            if(liveStreamView.videoCamera == "back"){
                liveStreamView.videoCamera = "front"
            }else{
                liveStreamView.videoCamera = "back"
            }
            break
        case "setVideoParameters":
            if let args = call.arguments as? Dictionary<String, Any>,
                let bitrate = args["bitrate"] as? Double,
                let resolution = args["resolution"] as? String,
                let fps = args["fps"] as? Double {
                liveStreamView.videoBitrate = bitrate
                liveStreamView.videoResolution = resolution
                liveStreamView.videoFps = fps
            }
            break
        case "setAudioParameters":
            if let args = call.arguments as? Dictionary<String, Any>,
                let bitrate = args["bitrate"] as? Int {
                liveStreamView.audioBitrate = bitrate
            }
            break
            
        case "toggleMute":
            liveStreamView.audioMuted = !liveStreamView.audioMuted
            break
        default:
            break
        }
    }
}

extension String {
    func toResolution() -> ApiVideoLiveStream.Resolutions{
        switch self {
        case "240p":
            return ApiVideoLiveStream.Resolutions.RESOLUTION_240
        case "360p":
            return ApiVideoLiveStream.Resolutions.RESOLUTION_360
        case "480p":
            return ApiVideoLiveStream.Resolutions.RESOLUTION_480
        case "720p":
            return ApiVideoLiveStream.Resolutions.RESOLUTION_720
        case "1080p":
            return ApiVideoLiveStream.Resolutions.RESOLUTION_1080
        case "2160p":
            return ApiVideoLiveStream.Resolutions.RESOLUTION_2160
        default:
            return ApiVideoLiveStream.Resolutions.RESOLUTION_720
        }
    }
    
}

class LiveStreamView: UIView{
    private var liveStream: ApiVideoLiveStream?
    private let channel: FlutterMethodChannel
    public init(frame: CGRect, channel: FlutterMethodChannel) {
        self.channel = channel
        super.init(frame: frame)
        self.liveStream = ApiVideoLiveStream(view: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc var videoFps: Double = 30 {
        didSet {
            if(videoFps == Double(liveStream!.videoFps)){
                return
            }
            liveStream?.videoFps = videoFps
        }
    }
    
    @objc var videoResolution: String = "720p" {
        didSet {
            let newResolution = videoResolution.toResolution()
            if(newResolution == liveStream!.videoResolution){
                return
            }
            liveStream?.videoResolution = newResolution
        }
    }
    
    @objc var videoBitrate: Double = -1  {
        didSet {
        }
    }
    
    @objc var videoCamera: String = "back" {
        didSet {
            var value : AVCaptureDevice.Position
            switch videoCamera {
            case "back":
                value = AVCaptureDevice.Position.back
            case "front":
                value = AVCaptureDevice.Position.front
            default:
                value = AVCaptureDevice.Position.back
            }
            if(value == liveStream!.videoCamera){
                return
            }
            liveStream?.videoCamera = value
        }
    }
    
    @objc var videoOrientation: String = "landscape" {
        didSet {
            var value : ApiVideoLiveStream.Orientation
            switch videoOrientation {
            case "landscape":
                value = ApiVideoLiveStream.Orientation.landscape
            case "portrait":
                value = ApiVideoLiveStream.Orientation.portrait
            default:
                value = ApiVideoLiveStream.Orientation.landscape
            }
            if(value == liveStream!.videoOrientation){
                return
            }
            liveStream?.videoOrientation = value
        }
    }
    
    @objc var audioMuted: Bool = false {
        didSet {
            if(audioMuted == liveStream!.audioMuted){
                return
            }
            liveStream?.audioMuted = audioMuted
        }
    }
    
    @objc var audioBitrate: Int = -1 {
        didSet {
            if(audioBitrate == liveStream!.audioBitrate){
                return
            }
            liveStream?.audioBitrate = audioBitrate
        }
    }
    
    @objc func startStreaming(streamKey: String, url: String) {
        liveStream?.onConnectionSuccess = {() in
            self.channel.invokeMethod("onConnectionSuccess", arguments: nil)
        }
        liveStream?.onConnectionFailed = {(code) in
            self.channel.invokeMethod("onConnectionFailed", arguments: code)
        }
        liveStream?.onDisconnect = {() in
            self.channel.invokeMethod("onDisconnect", arguments: nil)
        }
        liveStream?.startLiveStreamFlux(liveStreamKey: streamKey, rtmpServerUrl: url)
    }
    
    @objc func stopStreaming() {
        liveStream?.stopLiveStreamFlux()
    }
}
