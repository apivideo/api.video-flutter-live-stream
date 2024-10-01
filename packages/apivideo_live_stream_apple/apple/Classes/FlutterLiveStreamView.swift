import ApiVideoLiveStream
import AVFoundation
import Foundation

protocol FlutterLiveStreamViewDelegate {
    func connectionSuccess()
    func connectionFailed(_: String)
    func disconnection()
    func error(_: Error)
    func videoSizeChanged(_: CGSize)
}

class FlutterLiveStreamView: NSObject {
    private let previewTexture: PreviewTexture
    private let liveStream: ApiVideoLiveStream

    var delegate: FlutterLiveStreamViewDelegate?

    init(textureRegistry: FlutterTextureRegistry) throws {
        previewTexture = PreviewTexture(registry: textureRegistry)
        liveStream = try ApiVideoLiveStream(preview: previewTexture, initialAudioConfig: nil, initialVideoConfig: nil, initialCamera: nil)

        super.init()

        liveStream.delegate = self
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
            delegate?.videoSizeChanged(newValue.resolution)
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

    var cameraPosition: AVCaptureDevice.Position {
        get {
            liveStream.cameraPosition
        }
        set {
            liveStream.cameraPosition = newValue
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

extension FlutterLiveStreamView: ApiVideoLiveStreamDelegate {
    /// Called when the connection to the rtmp server is successful
    func connectionSuccess() {
        delegate?.connectionSuccess()
    }

    /// Called when the connection to the rtmp server failed
    func connectionFailed(_ message: String) {
        isStreaming = false
        delegate?.connectionFailed(message)
    }

    /// Called when the connection to the rtmp server is closed
    func disconnection() {
        isStreaming = false
        delegate?.disconnection()
    }

    /// Called if an error happened during the audio configuration
    func audioError(_ error: Error) {
        delegate?.error(error)
    }

    /// Called if an error happened during the video configuration
    func videoError(_ error: Error) {
        delegate?.error(error)
    }
}
