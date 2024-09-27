import AVFoundation
import Foundation
import HaishinKit

class PreviewTexture: NSObject, FlutterTexture {
    var videoOrientation: AVCaptureVideoOrientation = .portrait
    var isCaptureVideoPreviewEnabled: Bool = false

    private weak var currentStream: IOStream? {
        didSet {
            currentStream?.view = self
        }
    }

    private var currentSampleBuffer: CMSampleBuffer?
    private let registry: FlutterTextureRegistry
    private(set) var textureId: Int64 = 0

    public init(registry: FlutterTextureRegistry) {
        self.registry = registry
        super.init()
        textureId = self.registry.register(self)
    }

    func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
        guard let currentSampleBuffer = currentSampleBuffer,
              let imageBuffer = CMSampleBufferGetImageBuffer(currentSampleBuffer)
        else {
            return nil
        }

        return Unmanaged<CVPixelBuffer>.passRetained(imageBuffer)
    }

    func dispose() {
        registry.unregisterTexture(textureId)
    }
}

extension PreviewTexture: IOStreamView {
    // MARK: - IOStreamDrawable

    func attachStream(_ stream: IOStream?) {
        if Thread.isMainThread {
            currentStream = stream
        } else {
            DispatchQueue.main.async {
                self.currentStream = stream
            }
        }
    }

    func enqueue(_ sampleBuffer: CMSampleBuffer?) {
        currentSampleBuffer = sampleBuffer
        registry.textureFrameAvailable(textureId)
    }
}
