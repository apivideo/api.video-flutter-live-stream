import 'package:apivideo_live_stream/src/extensions/size_extensions.dart';
import 'package:apivideo_live_stream/src/listeners.dart';
import 'package:apivideo_live_stream/src/types/types.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'generated/live_stream_api.g.dart';
import 'platform_interface.dart';

/// Controller of the live streaming
class ApiVideoMobileLiveStreamPlatform extends ApiVideoLiveStreamPlatform
    implements LiveStreamFlutterApi {
  final LiveStreamHostApi messenger = LiveStreamHostApi();
  late ApiVideoLiveStreamEventsListener? _eventsListener;

  ApiVideoMobileLiveStreamPlatform() {
    LiveStreamFlutterApi.setUp(this,
        binaryMessenger: messenger.pigeonVar_binaryMessenger);
  }

  /// Registers this class as the default instance of [PathProviderPlatform].
  static void registerWith() {
    ApiVideoLiveStreamPlatform.instance = ApiVideoMobileLiveStreamPlatform();
  }

  @override
  Future<int?> initialize() async {
    return messenger.create();
  }

  @override
  Future<void> dispose() {
    return messenger.dispose();
  }

  @override
  Future<void> setVideoConfig(VideoConfig videoConfig) {
    return messenger.setVideoConfig(videoConfig.toNative());
  }

  @override
  Future<void> setAudioConfig(AudioConfig audioConfig) {
    return messenger.setAudioConfig(audioConfig.toNative());
  }

  @override
  Future<void> startStreaming(
      {required String streamKey, required String url}) {
    return messenger.startStreaming(streamKey: streamKey, url: url);
  }

  @override
  Future<void> stopStreaming() {
    return messenger.stopStreaming();
  }

  @override
  Future<void> startPreview() {
    return messenger.startPreview();
  }

  @override
  Future<void> stopPreview() {
    return messenger.stopPreview();
  }

  @override
  Future<bool> getIsStreaming() async {
    return messenger.getIsStreaming();
  }

  @override
  Future<void> setCameraPosition(CameraPosition cameraPosition) {
    return messenger.setCameraPosition(cameraPosition);
  }

  @override
  Future<CameraPosition> getCameraPosition() async {
    return messenger.getCameraPosition();
  }

  @override
  Future<void> setIsMuted(bool isMuted) {
    return messenger.setIsMuted(isMuted);
  }

  @override
  Future<bool> getIsMuted() async {
    return messenger.getIsMuted();
  }

  @override
  Future<Size?> getVideoSize() async {
    final resolution = await messenger.getVideoResolution();
    if (resolution != null) {
      return resolution.toSize();
    } else {
      return null;
    }
  }

  /// Builds the preview widget.
  @override
  Widget buildPreview(int textureId) {
    return Texture(textureId: textureId);
  }

  @override
  void setListener(ApiVideoLiveStreamEventsListener? listener) {
    _eventsListener = listener;
  }

  @override
  void onConnectionFailed(String message) {
    _eventsListener?.onConnectionFailed?.call(message);
  }

  @override
  void onIsConnectedChanged(bool isConnected) {
    if (isConnected) {
      _eventsListener?.onConnectionSuccess?.call();
    } else {
      _eventsListener?.onDisconnection?.call();
    }
  }

  @override
  void onVideoSizeChanged(NativeResolution resolution) {
    _eventsListener?.onVideoSizeChanged?.call(resolution.toSize());
  }

  @override
  void onError(String code, String message) {
    _eventsListener?.onError
        ?.call(PlatformException(code: code, message: message));
  }
}
