//
//  ApiVideoLiveStream.swift
//
import ApiVideoHaishinKit
import AVFoundation
import Foundation
import VideoToolbox

public class ApiVideoLiveStream{
    private var ratioConstraint: NSLayoutConstraint?
    private var mthkView: MTHKView?
    private var streamKey: String = ""
    private var url: String = ""
    private var rtmpStream: RTMPStream
    private var rtmpConnection = RTMPConnection()
    
    public var onConnectionSuccess: (() -> ())? = nil
    public var onConnectionFailed: ((String) -> ())? = nil
    public var onDisconnect: (() -> ())? = nil
    
    
    ///  Getter and Setter for an AudioConfig
    ///  Can't be updated
    public var audioConfig: AudioConfig {
        didSet{
            prepareAudio()
        }
    }
    
    /// Getter and Setter for a VideoConfig
    /// Can't be updated
    public var videoConfig: VideoConfig {
        didSet{
            prepareVideo()
        }
    }
    
    /// Getter and Setter for the Bitrate number for the video
    public var videoBitrate: Int? = nil {
        didSet{
            rtmpStream.videoSettings[.bitrate] = videoBitrate
        }
    }
    
    /// Camera position
    public var camera: AVCaptureDevice.Position = .back {
        didSet{
            attachCamera()
        }
    }
    
    /// Audio mute or not.
    public var isMuted: Bool = false {
        didSet{
            rtmpStream.audioSettings[.muted] = isMuted
        }
    }
    
    
    /// init a new ApiVideoLiveStream
    /// - Parameters:
    ///   - initialAudioConfig: The ApiVideoLiveStream's new AudioConfig
    ///   - initialVideoConfig: The ApiVideoLiveStream's new VideoConfig
    ///   - preview: UiView to display the preview of camera
    public init(initialAudioConfig: AudioConfig, initialVideoConfig: VideoConfig, preview: HKView) throws {
        let session = AVAudioSession.sharedInstance()
        
        // https://stackoverflow.com/questions/51010390/avaudiosession-setcategory-swift-4-2-ios-12-play-sound-on-silent
        if #available(iOS 10.0, *) {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        } else {
            session.perform(NSSelectorFromString("setCategory:withOptions:error:"), with: AVAudioSession.Category.playAndRecord, with: [
                AVAudioSession.CategoryOptions.allowBluetooth,
                AVAudioSession.CategoryOptions.defaultToSpeaker]
            )
            try session.setMode(.default)
        }
        try session.setActive(true)
        
        
        self.audioConfig = initialAudioConfig
        self.videoConfig = initialVideoConfig
        
        rtmpStream = RTMPStream(connection: rtmpConnection)
        if let orientation = DeviceUtil.videoOrientation(by: UIApplication.shared.statusBarOrientation) {
            self.rtmpStream.orientation = orientation
        }
        NotificationCenter.default.addObserver(self, selector: #selector(on(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)

        prepareVideo()
        prepareAudio()

        attachCamera()
        attachAudio()
        preview.attachStream(rtmpStream)
    }

    private func attachCamera() {
        rtmpStream.captureSettings[.isVideoMirrored] = camera == .front
        rtmpStream.attachCamera(DeviceUtil.device(withPosition: camera)) { error in
            print("======== Camera error ==========")
            print(error.description)
        }
    }

    private func prepareVideo() {
        rtmpStream.captureSettings = [
            .sessionPreset: AVCaptureSession.Preset.high,
            .fps: videoConfig.fps,
            .continuousAutofocus: true,
            .continuousExposure: true,
           // .preferredVideoStabilizationMode: AVCaptureVideoStabilizationMode.auto // Add latency to video
        ]
        rtmpStream.videoSettings = [
            .width: self.rtmpStream.orientation.isLandscape ? videoConfig.resolution.instance.width : videoConfig.resolution.instance.height,
            .height: self.rtmpStream.orientation.isLandscape ? videoConfig.resolution.instance.height : videoConfig.resolution.instance.width,
            .profileLevel: kVTProfileLevel_H264_Baseline_5_2,
            .bitrate: videoConfig.bitrate,
            .maxKeyFrameIntervalDuration: 1,
        ]
    }
    
    private func attachAudio() {
        rtmpStream.attachAudio(AVCaptureDevice.default(for: AVMediaType.audio)) { error in
            print("======== Audio error ==========")
            print(error.description)
        }
    }
    
    private func prepareAudio() {
        rtmpStream.audioSettings = [
            .bitrate: audioConfig.bitrate,
        ]
    }
    
    /// Start your livestream
    /// - Parameters:
    ///   - streamKey: The key of your live
    ///   - url: The url of your rtmp server, by default it's rtmp://broadcast.api.video/s
    /// - Returns: Void
    public func startStreaming(streamKey: String, url: String = "rtmp://broadcast.api.video/s") -> Void{
        self.streamKey = streamKey
        self.url = url
                
        rtmpConnection.addEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
        rtmpConnection.addEventListener(.ioError, selector: #selector(rtmpErrorHandler), observer: self)
        
        rtmpConnection.connect(url)
    }
    
    /// Stop your livestream
    /// - Returns: Void
    public func stopStreaming() -> Void{
        rtmpConnection.close()
        rtmpConnection.removeEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
        rtmpConnection.removeEventListener(.ioError, selector: #selector(rtmpErrorHandler), observer: self)
    }

    /// Stop your livestream
    /// - Returns: Void
    public func startPreview() -> Void {
        attachCamera()
        attachAudio()
    }

     /// Stop your livestream
    /// - Returns: Void
    public func stopPreview() -> Void {
        rtmpStream.attachCamera(nil)
        rtmpStream.attachAudio(nil)
    }
    
    @objc private func rtmpStatusHandler(_ notification: Notification) {
        let e = Event.from(notification)
        guard let data: ASObject = e.data as? ASObject, let code: String = data["code"] as? String else {
            return
        }
        switch code {
        case RTMPConnection.Code.connectSuccess.rawValue:
            if (self.onConnectionSuccess != nil) {
                self.onConnectionSuccess!()
            }
            rtmpStream.publish(self.streamKey)
            break
        case RTMPConnection.Code.connectClosed.rawValue:
            if (self.onDisconnect != nil) {
                self.onDisconnect!()
            }
            break
        case RTMPConnection.Code.connectFailed.rawValue:
            if (self.onConnectionFailed != nil) {
                self.onConnectionFailed!(code)
            }
            break
        default:
            break
        }
    }
    
    @objc
    private func rtmpErrorHandler(_ notification: Notification) {
        let e = Event.from(notification)
        print("rtmpErrorHandler: \(e)")
        DispatchQueue.main.async {
            self.rtmpConnection.connect(self.url)
        }
    }
    
    @objc
    private func on(_ notification: Notification) {
        guard let orientation = DeviceUtil.videoOrientation(by: UIApplication.shared.statusBarOrientation) else {
            return
        }
        rtmpStream.orientation = orientation

        rtmpStream.videoSettings = [
            .width: self.rtmpStream.orientation.isLandscape ? videoConfig.resolution.instance.width : videoConfig.resolution.instance.height,
            .height: self.rtmpStream.orientation.isLandscape ? videoConfig.resolution.instance.height : videoConfig.resolution.instance.width
        ]
    }
}

extension AVCaptureVideoOrientation {
    var isLandscape: Bool { return self == .landscapeLeft || self == .landscapeRight }
}
