import Foundation
import ApiVideoLiveStream
import AVFoundation

class FlutterLiveStreamView: NSObject {
    private let previewTexture: PreviewTexture
    private let liveStream: ApiVideoLiveStream
    
    private let eventChannel: FlutterEventChannel
    private var eventSink: FlutterEventSink?
    
    init(binaryMessenger: FlutterBinaryMessenger, textureRegistry: FlutterTextureRegistry) throws {
        previewTexture = PreviewTexture(registry: textureRegistry)
        liveStream = try ApiVideoLiveStream(preview: previewTexture, initialAudioConfig: nil, initialVideoConfig: nil, initialCamera: nil)
        eventChannel = FlutterEventChannel(name: "video.api.livestream/events", binaryMessenger: binaryMessenger)
        
        super.init()
        
        liveStream.delegate = self
        eventChannel.setStreamHandler(self)
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
            self.eventSink?(["type": "videoSizeChanged", "width": Double(newValue.resolution.size.width), "height": Double(newValue.resolution.size.height)])
            
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
            if (liveStream.cameraPosition == AVCaptureDevice.Position.back) {
                return "back"
            } else if (liveStream.cameraPosition == AVCaptureDevice.Position.front) {
                return "front"
            } else {
                return "other"
            }
        }
        set {
            if (newValue == "back") {
                liveStream.cameraPosition = AVCaptureDevice.Position.back
            } else if (newValue == "front") {
                liveStream.cameraPosition = AVCaptureDevice.Position.front
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
}

extension FlutterLiveStreamView: FlutterStreamHandler {
    func onListen(withArguments _: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
       return nil
   }

   func onCancel(withArguments _: Any?) -> FlutterError? {
       eventSink = nil
       return nil
   }
}


extension FlutterLiveStreamView: ApiVideoLiveStreamDelegate {
    /// Called when the connection to the rtmp server is successful
    func connectionSuccess() {
        self.eventSink?(["type": "connected"])
    }

    /// Called when the connection to the rtmp server failed
    func connectionFailed(_ code: String) {
        self.isStreaming = false
        self.eventSink?(["type": "connectionFailed", "message": "Failed to connect"])
    }

    /// Called when the connection to the rtmp server is closed
    func disconnection() {
        self.isStreaming = false
        self.eventSink?(["type": "disconnected"])
    }

    /// Called if an error happened during the audio configuration
    func audioError(_ error: Error) {
        print("audio error: \(error)")
    }

    /// Called if an error happened during the video configuration
    func videoError(_ error: Error) {
        print("video error: \(error)")
    }
}
