import AVFoundation
class LiveStreamHostApiImpl: LiveStreamHostApi {
    private let textureRegistry: FlutterTextureRegistry
    private let liveStreamFlutterApi: LiveStreamFlutterApi

    private var flutterView: FlutterLiveStreamView?

    init(textureRegistry: FlutterTextureRegistry, liveStreamFlutterApi: LiveStreamFlutterApi) {
        self.textureRegistry = textureRegistry
        self.liveStreamFlutterApi = liveStreamFlutterApi
    }

    func create() throws -> Int64 {
        flutterView?.dispose()
        flutterView = try FlutterLiveStreamView(textureRegistry: textureRegistry)
        flutterView!.delegate = self
        return flutterView!.textureId
    }

    func dispose() throws {
        flutterView?.dispose()
        flutterView = nil
    }

    func setVideoConfig(videoConfig: NativeVideoConfig, completion: @escaping (Result<Void, any Error>) -> Void) {
        flutterView!.videoConfig = videoConfig.toVideoConfig()
        completion(.success(()))
    }

    func setAudioConfig(audioConfig: NativeAudioConfig, completion: @escaping (Result<Void, any Error>) -> Void) {
        flutterView!.audioConfig = audioConfig.toAudioConfig()
        completion(.success(()))
    }

    func startStreaming(streamKey: String, url: String) throws {
        try flutterView!.startStreaming(streamKey: streamKey, url: url)
    }

    func stopStreaming() throws {
        flutterView!.stopStreaming()
    }

    func startPreview(completion: @escaping (Result<Void, any Error>) -> Void) {
        flutterView!.startPreview()
        completion(.success(()))
    }

    func stopPreview() throws {
        flutterView!.stopPreview()
    }

    func getIsStreaming() throws -> Bool {
        flutterView?.isStreaming ?? false
    }

    func getCameraPosition() throws -> CameraPosition {
        if flutterView!.cameraPosition == AVCaptureDevice.Position.back {
            return CameraPosition.back
        } else if flutterView!.cameraPosition == AVCaptureDevice.Position.front {
            return CameraPosition.front
        } else {
            return CameraPosition.other
        }
    }

    func setCameraPosition(position: CameraPosition, completion: @escaping (Result<Void, any Error>) -> Void) {
        switch position {
        case .back:
            flutterView!.cameraPosition = AVCaptureDevice.Position.back
        case .front:
            flutterView!.cameraPosition = AVCaptureDevice.Position.front
        case .other:
            completion(.failure(NSError(domain: "cameraPosition", code: 0, userInfo: ["message": "Invalid camera position"])))
            return
        }
        completion(.success(()))
    }

    func getIsMuted() throws -> Bool {
        flutterView?.isMuted ?? false
    }

    func setIsMuted(isMuted: Bool) throws {
        flutterView!.isMuted = isMuted
    }

    func getVideoResolution() throws -> NativeResolution? {
        flutterView?.videoConfig.resolution.toNativeResolution()
    }
    
    func setZoomRatio(zoomRatio: Double) throws {
        flutterView!.zoomRatio = zoomRatio
    }
    
    func getZoomRatio() throws -> Double {
        flutterView?.zoomRatio ?? 1.0
    }
    
    func getMaxZoomRatio() throws -> Double {
        flutterView?.maxZoomRatio ?? 1.0
    }
}

extension LiveStreamHostApiImpl: FlutterLiveStreamViewDelegate {
    func connectionSuccess() {
        liveStreamFlutterApi.onIsConnectedChanged(isConnected: true, completion: { _ in })
    }

    func disconnection() {
        liveStreamFlutterApi.onIsConnectedChanged(isConnected: false, completion: { _ in })
    }

    func connectionFailed(_ message: String) {
        liveStreamFlutterApi.onConnectionFailed(message: message, completion: { _ in })
    }

    func error(_ error: any Error) {
        liveStreamFlutterApi.onError(code: "native-error", message: error.localizedDescription, completion: { _ in })
    }

    func videoSizeChanged(_ size: CGSize) {
        liveStreamFlutterApi.onVideoSizeChanged(resolution: size.toNativeResolution(), completion: { _ in })
    }
}
