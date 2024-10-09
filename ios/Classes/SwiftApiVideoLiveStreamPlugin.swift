import ApiVideoLiveStream
import AVFoundation
import Flutter
import HaishinKit
import Network
import UIKit

public class SwiftApiVideoLiveStreamPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let binaryMessenger = registrar.messenger()

        let instanceManager = InstanceManager()

        let liveStreamFlutterApi = LiveStreamFlutterApi(binaryMessenger: binaryMessenger)
        let liveStreamHostApiImpl = LiveStreamHostApiImpl(instanceManager: instanceManager, textureRegistry: registrar.textures(), liveStreamFlutterApi: liveStreamFlutterApi)
        LiveStreamHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: liveStreamHostApiImpl)

        let cameraProviderHostApiImpl = CameraProviderHostApiImpl()
        CameraProviderHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: cameraProviderHostApiImpl)

        let cameraInfoHostApiImpl = CameraInfoHostApiImpl()
        CameraInfoHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: cameraInfoHostApiImpl)

        let cameraSettingsHostApiImpl = CameraSettingsHostApiImpl(instanceManager: instanceManager)
        CameraSettingsHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: cameraSettingsHostApiImpl)
    }
}
