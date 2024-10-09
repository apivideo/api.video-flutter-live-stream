import AVFoundation

enum DeviceProvider {
    static func getAvailableCamera() -> [AVCaptureDevice] {
        AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInUltraWideCamera, .builtInTelephotoCamera], mediaType: .video, position: .unspecified).devices
    }

    static func getCamera(uniqueID: String) -> AVCaptureDevice? {
        DeviceProvider.getAvailableCamera().first(where: { $0.uniqueID == uniqueID })
    }
}

class CameraProviderHostApiImpl: CameraProviderHostApi {
    func getAvailableCameraIds() throws -> [String] {
        DeviceProvider.getAvailableCamera().map { $0.uniqueID }
    }
}
