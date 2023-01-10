import AVFoundation
import Flutter
import Network
import UIKit
import HaishinKit
import ApiVideoLiveStream

enum ApiVideoLiveStreamError: Error {
    case invalidAVSession
}

public class SwiftApiVideoLiveStreamPlugin: NSObject, FlutterPlugin {
    private let binaryMessenger: FlutterBinaryMessenger
    private let channel: FlutterMethodChannel
    private let registry: FlutterTextureRegistry
    private var flutterView: FlutterLiveStreamView?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftApiVideoLiveStreamPlugin(registrar: registrar)
        registrar.publish(instance)
    }

    public init(registrar: FlutterPluginRegistrar) {
        self.binaryMessenger = registrar.messenger()
        self.channel = FlutterMethodChannel(name: "video.api.livestream/controller", binaryMessenger: binaryMessenger)
        self.registry = registrar.textures()
        super.init()
        
        registrar.addMethodCallDelegate(self, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "create":
            flutterView?.dispose()
            do {
                flutterView = try FlutterLiveStreamView(binaryMessenger: binaryMessenger, textureRegistry: registry)
                if let previewTexture = flutterView?.textureId {
                    result(["textureId": previewTexture])
                } else {
                    result(FlutterError(code: "failed_to_create_live_stream", message: "Failed to create camera preview surface", details: nil))
                }
            } catch {
                result(FlutterError(code: "failed_to_create_live_stream", message: error.localizedDescription, details: nil))
            }
        case "dispose":
            flutterView?.dispose()
        case "setVideoConfig":
            guard let flutterView = flutterView else {
                result(FlutterError(code: "missing_live_stream", message: "Live stream must exist at this point", details: nil))
                return
            }
            guard let videoParameters = call.arguments as? [String: Any] else {
                result(FlutterError(code: "invalid_parameter", message: "Invalid video config", details: nil))
                return
            }
            flutterView.videoConfig = videoParameters.toVideoConfig()
            result(nil)
        case "setAudioConfig":
            guard let flutterView = flutterView else {
                result(FlutterError(code: "missing_live_stream", message: "Live stream must exist at this point", details: nil))
                return
            }
            guard let audioParameters = call.arguments as? [String: Any] else {
                result(FlutterError(code: "invalid_parameter", message: "Invalid audio config", details: nil))
                return
            }
            flutterView.audioConfig = audioParameters.toAudioConfig()
            result(nil)
        case "startPreview":
            guard let flutterView = flutterView else {
                result(FlutterError(code: "missing_live_stream", message: "Live stream must exist at this point", details: nil))
                return
            }
            flutterView.startPreview()
            result(nil)
        case "stopPreview":
            guard let flutterView = flutterView else {
                result(FlutterError(code: "missing_live_stream", message: "Live stream must exist at this point", details: nil))
                return
            }
            flutterView.stopPreview()
            result(nil)
        case "startStreaming":
            if let args = call.arguments as? [String: Any] {
                let streamKey = args["streamKey"] as? String
                let url = args["url"] as? String
                if streamKey == nil {
                    result(FlutterError(code: "missing_stream_key", message: "Stream key is missing", details: nil))
                } else if url == nil {
                    result(FlutterError(code: "missing_rtmp_url", message: "RTMP URL is missing", details: nil))
                } else {
                    guard let flutterView = flutterView else {
                        result(FlutterError(code: "missing_live_stream", message: "Live stream must exist at this point", details: nil))
                        return
                    }
                    do {
                        try flutterView.startStreaming(streamKey: streamKey!, url: url!)
                        result(nil)
                    } catch {
                        result(FlutterError(code: "missing_live_stream", message: error.localizedDescription, details: nil))
                    }
                }
            }
        case "stopStreaming":
            guard let flutterView = flutterView else {
                result(FlutterError(code: "missing_live_stream", message: "Live stream must exist at this point", details: nil))
                return
            }
            flutterView.stopStreaming()
            result(nil)
        case "getIsStreaming":
            guard let flutterView = flutterView else {
                result(FlutterError(code: "missing_live_stream", message: "Live stream must exist at this point", details: nil))
                return
            }
            result(["isStreaming": flutterView.isStreaming])
        case "getCameraPosition":
            guard let flutterView = flutterView else {
                result(FlutterError(code: "missing_live_stream", message: "Live stream must exist at this point", details: nil))
                return
            }
            result(["position": flutterView.cameraPosition])
        case "setCameraPosition":
            guard let flutterView = flutterView else {
                result(FlutterError(code: "missing_live_stream", message: "Live stream must exist at this point", details: nil))
                return
            }
            guard let args = call.arguments as? [String: Any],
                 let cameraPosition = args["position"] as? String else {
                result(FlutterError(code: "invalid_parameter", message: "Invalid camera position", details: nil))
                return
            }
            flutterView.cameraPosition = cameraPosition
            result(nil)
        case "getIsMuted":
            guard let flutterView = flutterView else {
                result(FlutterError(code: "missing_live_stream", message: "Live stream must exist at this point", details: nil))
                return
            }
            result(["isMuted": flutterView.isMuted])
        case "setIsMuted":
            guard let flutterView = flutterView else {
                result(FlutterError(code: "missing_live_stream", message: "Live stream must exist at this point", details: nil))
                return
            }
            guard let args = call.arguments as? [String: Any],
                 let isMuted = args["isMuted"] as? Bool else {
                result(FlutterError(code: "invalid_parameter", message: "Invalid isMuted", details: nil))
                return
            }
            flutterView.isMuted = isMuted
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
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
                           fps: self["fps"] as! Float64)
    }
}
