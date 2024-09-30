import 'package:apivideo_live_stream/apivideo_live_stream.dart';
import 'package:apivideo_live_stream/src/listeners.dart';
import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class ApiVideoLiveStreamPlatform extends PlatformInterface {
  /// Constructs a ApiVideoPlayerPlatform.
  ApiVideoLiveStreamPlatform() : super(token: _token);

  static final Object _token = Object();

  static ApiVideoLiveStreamPlatform _instance = _getDefaultPlatform();

  static ApiVideoLiveStreamPlatform _getDefaultPlatform() {
    return ApiVideoMobileLiveStreamPlatform();
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

  Future<CameraPosition> getCameraPosition() {
    throw UnimplementedError('getCameraPosition() has not been implemented.');
  }

  Future<void> setCameraPosition(CameraPosition cameraPosition) {
    throw UnimplementedError('setCameraPosition() has not been implemented.');
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

  Future<void> setZoomRatio(double zoomRatio) {
    throw UnimplementedError('setZoomRatio() has not been implemented.');
  }

  Future<double> getZoomRatio() {
    throw UnimplementedError('getZoomRatio() has not been implemented.');
  }

  Future<double> getMaxZoomRatio() {
    throw UnimplementedError('getMaxZoomRatio() has not been implemented.');
  }

  /// Returns a Stream of [LiveStreamingEvent]s.
  void setListener(ApiVideoLiveStreamEventsListener? listener) {
    throw UnimplementedError('setListener() has not been implemented.');
  }

  Widget buildPreview(int textureId) {
    throw UnimplementedError('buildPreview() has not been implemented.');
  }
}
