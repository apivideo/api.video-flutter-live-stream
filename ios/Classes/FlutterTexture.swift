import Foundation
import HaishinKit
import AVFoundation

class PreviewTexture: NSObject, FlutterTexture {
    var videoOrientation: AVCaptureVideoOrientation = .portrait
    var position: AVCaptureDevice.Position = .back
    var videoFormatDescription: CMVideoFormatDescription?

    private var currentSampleBuffer: CMSampleBuffer?
    private let registry: FlutterTextureRegistry
    private let queue = DispatchQueue(label: "api.video.flutter.livestream.pixelBufferSynchronizationQueue")
    private var currentStream: NetStream?
    private(set) var textureId: Int64 = 0

    public init(registry: FlutterTextureRegistry) {
        self.registry = registry
        super.init()
        textureId = self.registry.register(self)
    }

    func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
        guard let currentSampleBuffer = currentSampleBuffer,
              let imageBuffer = CMSampleBufferGetImageBuffer(currentSampleBuffer) else {
                 return nil
             }

        var pixelBuffer: Unmanaged<CVPixelBuffer>?
        queue.sync {
            pixelBuffer = Unmanaged<CVPixelBuffer>.passRetained(imageBuffer)
        }
        return pixelBuffer
    }
    
    func dispose() {
        registry.unregisterTexture(textureId)
    }
}

extension PreviewTexture: NetStreamDrawable {
    // MARK: - NetStreamDrawable
    func attachStream(_ stream: NetStream?) {
        guard let stream = stream else {
            self.currentStream = nil
            return
        }
        stream.lockQueue.async {
            stream.mixer.drawable = self
            self.currentStream = stream
            stream.mixer.startRunning()
        }
    }

    func enqueue(_ sampleBuffer: CMSampleBuffer?) {
        currentSampleBuffer = sampleBuffer
        self.registry.textureFrameAvailable(textureId)
    }
}
