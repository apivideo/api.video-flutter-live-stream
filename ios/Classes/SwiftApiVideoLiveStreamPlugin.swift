import ApiVideoLiveStream
import AVFoundation
import Flutter
import HaishinKit
import Network
import UIKit

public class SwiftApiVideoLiveStreamPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let binaryMessenger = registrar.messenger()

        let liveStreamFlutterApi = LiveStreamFlutterApi(binaryMessenger: binaryMessenger)
        let liveStreamHostApiImpl = LiveStreamHostApiImpl(textureRegistry: registrar.textures(), liveStreamFlutterApi: liveStreamFlutterApi)
        LiveStreamHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: liveStreamHostApiImpl)
    }
}
