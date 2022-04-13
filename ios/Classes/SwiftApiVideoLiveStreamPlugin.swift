import Flutter
import UIKit
import AVFoundation
import Network
import ApiVideoHaishinKit

enum ApiVideoLiveStreamError: Error {
    case invalidAVSession
}


public class SwiftApiVideoLiveStreamPlugin: NSObject, FlutterPlugin {
    private let channel: FlutterMethodChannel
    private let registry: FlutterTextureRegistry
    private var liveStream: ApiVideoLiveStream?
    private var previewTexture: PreviewTexture?
    private var textureId: Int64?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "video.api.livestream/controller", binaryMessenger: registrar.messenger())
                
        let instance = SwiftApiVideoLiveStreamPlugin(channel: channel, registry: registrar.textures())
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public init(channel: FlutterMethodChannel, registry: FlutterTextureRegistry) {
        self.channel = channel
        self.registry = registry
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "create":
            if let args = call.arguments as? Dictionary<String, Any>,
               let audioParameters = args["audioParameters"] as? Dictionary<String, Any>,
               let videoParameters = args["videoParameters"] as? Dictionary<String, Any> {
                dispose()
                do {
                    let videoConfig = videoParameters.toVideoConfig()
                    previewTexture = PreviewTexture(frame: CGRect(x: 0, y: 0, width: videoConfig.resolution.instance.width, height: videoConfig.resolution.instance.height))
                    liveStream = try createLiveStream(initialAudioConfig: audioParameters.toAudioConfig(), initialVideoConfig: videoConfig, preview: previewTexture!)
                   
                    textureId = registry.register(previewTexture!)
                    if let textureId = textureId {
                        previewTexture!.onFrameAvailable = {
                            self.registry.textureFrameAvailable(textureId)
                        }
                        result(["textureId": textureId])
                    } else {
                        result(FlutterError.init(code: "failed_to_create_live_stream", message: "Failed to create camera preview surface", details: nil))
                    }
                } catch {
                    result(FlutterError.init(code: "failed_to_create_live_stream", message: error.localizedDescription, details: nil))
                }
            }
            break
        case "startStreaming":
            if let args = call.arguments as? Dictionary<String, Any> {
                 let streamKey = args["streamKey"] as? String
                 let url = args["url"] as? String
                 if (streamKey == nil) {
                    result(FlutterError.init(code: "missing_stream_key", message: "Stream key is missing", details: nil))
                 } else if (url == nil) {
                    result(FlutterError.init(code: "missing_rtmp_url", message:  "RTMP URL is missing", details: nil))
                 } else {
                     if let liveStream = liveStream {
                         liveStream.startStreaming(streamKey: streamKey!, url: url!)
                         result(nil)
                     } else {
                         result(FlutterError.init(code: "missing_live_stream", message: "Live stream must exist at this point", details: nil))
                     }
                 }
            }
            break
        case "stopStreaming":
            liveStream?.stopStreaming()
            break
        case "switchCamera":
            if let liveStream = liveStream {
                if(liveStream.camera == .back){
                    liveStream.camera = .front
                }else{
                    liveStream.camera = .back
                }
                result(nil)
            } else {
                result(FlutterError.init(code: "missing_live_stream", message: "Live stream must exist at this point", details: nil))
            }
            break
        case "setVideoParameters":
            if let videoParameters = call.arguments as? Dictionary<String, Any> {
                liveStream?.videoConfig = videoParameters.toVideoConfig()
            }
            break
        case "setAudioParameters":
            if let audioParameters = call.arguments as? Dictionary<String, Any> {
               liveStream?.audioConfig = audioParameters.toAudioConfig()
            }
            break
            
        case "toggleMute":
            if let liveStream = liveStream {
                liveStream.isMuted = !liveStream.isMuted
                result(nil)
            } else {
                result(FlutterError.init(code: "missing_live_stream", message: "Live stream must exist at this point", details: nil))
            }
            break
        case "dispose":
            dispose()
            break
        default:
            break
        }
    }
    
    func createLiveStream(initialAudioConfig: AudioConfig, initialVideoConfig: VideoConfig, preview: HKView) throws -> ApiVideoLiveStream {
        let liveStream = try ApiVideoLiveStream(initialAudioConfig: initialAudioConfig, initialVideoConfig: initialVideoConfig, preview: preview)
        liveStream.onConnectionSuccess = {() in
            self.channel.invokeMethod("onConnectionSuccess", arguments: nil)
        }
        liveStream.onConnectionFailed = {(code) in
            self.channel.invokeMethod("onConnectionFailed", arguments: code)
        }
        liveStream.onDisconnect = {() in
            self.channel.invokeMethod("onDisconnect", arguments: nil)
        }
        return liveStream
    }
    
    func dispose() {
        liveStream?.stopStreaming()
        previewTexture?.close()
        if let textureId = textureId {
            registry.unregisterTexture(textureId)
        }
    }
}

class PreviewTexture: HKView, FlutterTexture {
    let queue = DispatchQueue(label: "api.video.flutter.livestream.pixelBufferSynchronizationQueue")
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.newSampleBuffer = { (currentSampleBuffer) in
            let newPixelBuffer = CMSampleBufferGetImageBuffer(currentSampleBuffer)
            self.queue.sync {
                self.latestPixelBuffer = newPixelBuffer
            }
            self.onFrameAvailable?()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var onFrameAvailable: (() -> Void)?
    
    private var latestPixelBuffer: CVPixelBuffer?

    func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
        var pixelBuffer:  Unmanaged<CVPixelBuffer>? = nil;
        if let latestPixelBuffer = latestPixelBuffer {
            self.queue.sync {
                pixelBuffer = Unmanaged<CVPixelBuffer>.passRetained(latestPixelBuffer)
                self.latestPixelBuffer = nil
            }
        }
        return pixelBuffer
    }
    
    func close() {
        latestPixelBuffer = nil
    }
}


extension String {
    func toResolution() -> Resolution {
        switch self {
        case "240p":
            return Resolution.RESOLUTION_240
        case "360p":
            return Resolution.RESOLUTION_360
        case "480p":
            return Resolution.RESOLUTION_480
        case "720p":
            return Resolution.RESOLUTION_720
        case "1080p":
            return Resolution.RESOLUTION_1080
        default:
            return Resolution.RESOLUTION_720
        }
    }
}

extension Dictionary where Key == String {
    func toAudioConfig() -> AudioConfig {
       return AudioConfig(bitrate: self["bitrate"] as! Int)
    }

    func toVideoConfig() -> VideoConfig {
        return VideoConfig(bitrate: self["bitrate"] as! Int,
                           resolution: (self["resolution"] as! String).toResolution(),
                           fps: self["fps"] as! Int)
    }
}
