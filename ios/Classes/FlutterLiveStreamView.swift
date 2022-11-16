import Foundation
import ApiVideoLiveStream
import AVFoundation

class FlutterLiveStreamView: NSObject, FlutterStreamHandler {
    private let previewTexture: PreviewTexture
    private let liveStream: ApiVideoLiveStream
    
    private let eventChannel: FlutterEventChannel
    private var eventSink: FlutterEventSink?
    
    init(binaryMessenger: FlutterBinaryMessenger, textureRegistry: FlutterTextureRegistry) throws {
        previewTexture = PreviewTexture(registry: textureRegistry)
        liveStream = try ApiVideoLiveStream(initialAudioConfig: nil, initialVideoConfig: nil, preview: previewTexture)
        eventChannel = FlutterEventChannel(name: "video.api.livestream/events", binaryMessenger: binaryMessenger)
        
        super.init()
        
        eventChannel.setStreamHandler(self)
        
        liveStream.onConnectionSuccess = { () in
            self.eventSink?(["type": "connected"])
        }
        liveStream.onDisconnect = { () in
            self.isStreaming = false
            self.eventSink?(["type": "disconnected"])
        }
        liveStream.onConnectionFailed = { code in
            self.isStreaming = false
            self.eventSink?(["type": "connectionFailed"])
        }
    }
    
   
    var textureId: Int64 {
        previewTexture.textureId
    }
    
    private(set) var isStreaming = false
    
    var videoConfig: VideoConfig {
        get {
            liveStream.videoConfig
        }
        set {
            self.eventSink?(["type": "videoSizeChanged", "width": Double(newValue.resolution.instance.width), "height": Double(newValue.resolution.instance.height)])
            
            liveStream.videoConfig = newValue
        }
    }
    
    var audioConfig: AudioConfig {
        get {
            liveStream.audioConfig
        }
        set {
            liveStream.audioConfig = newValue
        }
    }
    
    var isMuted: Bool {
       get {
           liveStream.isMuted
       }
       set {
           liveStream.isMuted = newValue
       }
   }
    
    var cameraPosition: String {
        get {
            if (liveStream.camera == AVCaptureDevice.Position.back) {
                return "back"
            } else if (liveStream.camera == AVCaptureDevice.Position.front) {
                return "front"
            } else {
                return "other"
            }
        }
        set {
            if (newValue == "back") {
                liveStream.camera = AVCaptureDevice.Position.back
            } else if (newValue == "front") {
                liveStream.camera = AVCaptureDevice.Position.front
            }
        }
    }
    
    func dispose() {
        liveStream.stopStreaming()
        liveStream.stopPreview()
      
        previewTexture.dispose()
    }
    
    func startPreview() {
        liveStream.startPreview()
    }
  
    func stopPreview() {
        liveStream.stopPreview()
    }
    
    func startStreaming(streamKey: String, url: String) throws {
        try liveStream.startStreaming(streamKey: streamKey, url: url)
        isStreaming = true
    }
  
    func stopStreaming() {
        liveStream.stopStreaming()
        isStreaming = false
    }
    
    func onListen(withArguments _: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
       return nil
   }

   func onCancel(withArguments _: Any?) -> FlutterError? {
       eventSink = nil
       return nil
   }
}
