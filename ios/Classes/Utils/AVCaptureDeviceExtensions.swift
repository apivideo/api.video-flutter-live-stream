import AVFoundation

extension AVCaptureDevice.Position {
    func toNativeCameraLensDirection() -> NativeCameraLensDirection {
        switch self {
        case .back:
            return .back
        case .front:
            return .front
        case .unspecified:
            return .other
        @unknown default:
            return .other
        }
    }
}
