import AVFoundation

class CameraInfoHostApiImpl: CameraInfoHostApi {
    func getSensorRotationDegrees(cameraId _: String) throws -> Int64 {
        90
    }

    func getLensDirection(cameraId: String) throws -> NativeCameraLensDirection {
        let captureDevice = DeviceProvider.getCamera(uniqueID: cameraId)!
        return captureDevice.position.toNativeCameraLensDirection()
    }

    func getMinZoomRatio(cameraId: String) throws -> Double {
        let captureDevice = DeviceProvider.getCamera(uniqueID: cameraId)!
        return captureDevice.minAvailableVideoZoomFactor
    }

    func getMaxZoomRatio(cameraId: String) throws -> Double {
        let captureDevice = DeviceProvider.getCamera(uniqueID: cameraId)!
        return captureDevice.maxAvailableVideoZoomFactor
    }
}
