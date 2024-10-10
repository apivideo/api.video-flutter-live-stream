import 'package:apivideo_live_stream/apivideo_live_stream.dart';
import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class ApiVideoLiveStreamPlatform extends PlatformInterface {
  /// Constructs a ApiVideoPlayerPlatform.
  ApiVideoLiveStreamPlatform() : super(token: _token);

  static final Object _token = Object();

  static ApiVideoLiveStreamPlatform _instance = _getDefaultPlatform();

  static ApiVideoLiveStreamPlatform _getDefaultPlatform() {
    return ApiVideoMessengerLiveStreamPlatform();
  }

  /// The default instance of [ApiVideoLiveStreamPlatform] to use.
  ///
  /// Defaults to [_PlatformImplementation].
  static ApiVideoLiveStreamPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ApiVideoLiveStreamPlatform] when
  /// they register themselves.
  static set instance(ApiVideoLiveStreamPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Gets list of available cameras.
  ///
  /// This method returns an empty list when no cameras are available.
  Future<List<CameraInfo>> getAvailableCameraInfos() {
    throw UnimplementedError('getAvailableCameraInfos() is not implemented.');
  }

  /// Creates a new live stream instance
  Future<int?> initialize() {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// Disposes the live stream instance
  Future<void> dispose() {
    throw UnimplementedError('dispose() has not been implemented.');
  }

  Future<void> setVideoConfig(VideoConfig videoConfig) {
    throw UnimplementedError('setVideoConfig() has not been implemented.');
  }

  Future<void> setAudioConfig(AudioConfig audioConfig) {
    throw UnimplementedError('setAudioConfig() has not been implemented.');
  }

  Future<void> startStreaming(
      {required String streamKey, required String url}) {
    throw UnimplementedError('startStreaming() has not been implemented.');
  }

  Future<void> stopStreaming() {
    throw UnimplementedError('stopStreaming() has not been implemented.');
  }

  Future<void> startPreview() {
    throw UnimplementedError('startPreview() has not been implemented.');
  }

  Future<void> stopPreview() {
    throw UnimplementedError('stopPreview() has not been implemented.');
  }

  Future<bool> getIsStreaming() {
    throw UnimplementedError('getIsStreaming() has not been implemented.');
  }

  Future<String> getCameraId() {
    throw UnimplementedError(
        'getCameraLensDirection() has not been implemented.');
  }

  Future<void> setCameraId(String name) {
    throw UnimplementedError('setCameraName() has not been implemented.');
  }

  Future<bool> getIsMuted() {
    throw UnimplementedError('getIsMuted() has not been implemented.');
  }

  Future<void> setIsMuted(bool isMuted) {
    throw UnimplementedError('setIsMuted() has not been implemented.');
  }

  Future<Size?> getVideoSize() {
    throw UnimplementedError('getVideoSize() has not been implemented.');
  }

  Future<CameraInfo> getCameraInfo() {
    throw UnimplementedError('getCameraInfo() has not been implemented.');
  }

  Future<CameraSettings> getCameraSettings() {
    throw UnimplementedError('getCameraSettings() has not been implemented.');
  }

  /// Returns a Stream of [LiveStreamingEvent]s.
  void setListener(ApiVideoLiveStreamEventsListener? listener) {
    throw UnimplementedError('setListener() has not been implemented.');
  }

  Widget buildPreview(int textureId) {
    throw UnimplementedError('buildPreview() has not been implemented.');
  }
}
