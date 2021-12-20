import Flutter
import UIKit
import LiveStreamIos
import AVFoundation
import Network

public class SwiftApivideolivestreamPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "apivideolivestream", binaryMessenger: registrar.messenger())
        
        let factory = LiveStreamViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "<platform-view-type>")
        
        let instance = SwiftApivideolivestreamPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result("iOS " + UIDevice.current.systemVersion)
    }
}

class LiveStreamViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
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
            binaryMessenger: messenger
        )
    }
}

class LiveStreamNativeView: NSObject, FlutterPlatformView {
    private var liveStreamView: LiveStreamView
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        let channelFirstConnection = FlutterMethodChannel(name: "apivideolivestream_\(viewId)", binaryMessenger: messenger!)
        liveStreamView = LiveStreamView(frame: frame, channel: channelFirstConnection)
        super.init()
        channelFirstConnection.setMethodCallHandler { [weak self] (call, result) -> Void in
            self?.handlerMethodCall(call, result)
        }
    }
    
    func view() -> UIView {
        return liveStreamView
    }
    
    func handlerMethodCall(_ call: FlutterMethodCall, _ result: FlutterResult)  {
        switch call.method {
        case "startStreaming":
            liveStreamView.startStreaming()
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
        case "setLivestreamKey":
            let key = call.arguments as! String
            liveStreamView.liveStreamKey = key
        case "setParam":
            let str = call.arguments as! String
            let data = str.data(using: .utf8)
            do {
                let param = try JSONDecoder().decode(Parameters.self, from: data!)
                liveStreamView.liveStreamKey = param.liveStreamKey
                liveStreamView.rtmpServerUrl = param.rtmpServerUrl
                liveStreamView.videoFps = param.videoFps
                liveStreamView.videoResolution = param.videoResolution
                liveStreamView.videoBitrate = param.videoBitrate
                liveStreamView.videoCamera = param.videoCamera
                liveStreamView.videoOrientation = param.videoOrientation
                liveStreamView.audioMuted = param.audioMuted
                liveStreamView.audioBitrate = param.audioBitrate
            } catch let error as NSError{
                print(error)
            }
        default:
            break
        }
    }
    
    func createNativeView(view nativeView: UIView){
        nativeView.backgroundColor = UIColor.blue
        let nativeLabel = UILabel()
        nativeLabel.text = "Native text from iOS"
        nativeLabel.textColor = UIColor.white
        nativeLabel.textAlignment = .center
        nativeLabel.frame = CGRect(x: 0, y: 0, width: 180, height: 48.0)
        nativeView.addSubview(nativeLabel)
    }
}

class LiveStreamView: UIView{
    private var apiVideo: ApiVideoLiveStream?
    private var channel: FlutterMethodChannel?
    public init(frame: CGRect, channel: FlutterMethodChannel) {
        self.channel = channel
        super.init(frame: frame)
        apiVideo = ApiVideoLiveStream(view: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getResolutionFromString(resolutionString: String) -> ApiVideoLiveStream.Resolutions{
        switch resolutionString {
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
    
    @objc override func didMoveToWindow() {
        super.didMoveToWindow()
    }
    
    @objc var liveStreamKey: String = "" {
        didSet {
        }
    }
    
    @objc var rtmpServerUrl: String? {
        didSet {
        }
    }
    
    @objc var videoFps: Double = 30 {
        didSet {
            if(videoFps == Double(apiVideo!.videoFps)){
                return
            }
            apiVideo?.videoFps = videoFps
        }
    }
    
    @objc var videoResolution: String = "720p" {
        didSet {
            let newResolution = getResolutionFromString(resolutionString: videoResolution)
            if(newResolution == apiVideo!.videoResolution){
                return
            }
            apiVideo?.videoResolution = newResolution
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
            if(value == apiVideo?.videoCamera){
                return
            }
            apiVideo?.videoCamera = value
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
            if(value == apiVideo?.videoOrientation){
                return
            }
            apiVideo?.videoOrientation = value
        }
    }
    
    @objc var audioMuted: Bool = false {
        didSet {
            if(audioMuted == apiVideo!.audioMuted){
                return
            }
            apiVideo?.audioMuted = audioMuted
        }
    }
    
    @objc var audioBitrate: Double = -1 {
        didSet {
        }
    }
    
    @objc func startStreaming() {
        channel?.invokeMethod("setParam", arguments: nil)
        apiVideo!.startLiveStreamFlux(liveStreamKey: self.liveStreamKey, rtmpServerUrl: self.rtmpServerUrl)
        apiVideo?.onConnectionSuccess = {() in
            self.channel?.invokeMethod("onConnectionSuccess", arguments: nil)
        }
        apiVideo!.onConnectionFailed = {(code) in
            self.channel?.invokeMethod("onConnectionFailed", arguments: code)
        }
        apiVideo!.onDisconnect = {() in
            self.channel?.invokeMethod("onDisconnect", arguments: nil)
        }
    }
    
    @objc func stopStreaming() {
        apiVideo!.stopLiveStreamFlux()
    }
}

struct Parameters: Codable {
    let liveStreamKey: String
    let rtmpServerUrl: String
    let videoFps: Double
    let videoResolution: String
    let videoBitrate: Double
    let videoCamera: String
    let videoOrientation: String
    let audioMuted: Bool
    let audioBitrate: Double

    private enum CodingKeys: String, CodingKey {
        case liveStreamKey = "liveStreamKey"
        case videoFps = "videoFps"
        case videoBitrate = "videoBitrate"
        case videoOrientation = "videoOrientation"
        case audioBitrate = "audioBitrate"
        case rtmpServerUrl = "rtmpServerUrl"
        case videoResolution = "videoResolution"
        case videoCamera = "videoCamera"
        case audioMuted = "audioMuted"
    }
}
