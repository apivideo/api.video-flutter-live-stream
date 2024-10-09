class InstanceManager {
    private(set) var liveStream: LiveStreamViewManager?

    func create(textureRegistry: FlutterTextureRegistry) throws -> LiveStreamViewManager {
        liveStream?.dispose()
        let flutterView = try LiveStreamViewManager(textureRegistry: textureRegistry)
        liveStream = flutterView
        return flutterView
    }
}
