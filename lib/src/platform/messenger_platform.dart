import 'package:apivideo_live_stream/apivideo_live_stream.dart';
import 'package:apivideo_live_stream/src/platform/extensions/size_extensions.dart';
import 'package:apivideo_live_stream/src/platform_interface/platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'generated/live_stream_api.g.dart';
import 'types/camera/messenger_camera_info.dart';
import 'types/camera/messenger_camera_settings.dart';

/// Controller of the live streaming
class ApiVideoMessengerLiveStreamPlatform extends ApiVideoLiveStreamPlatform
    implements LiveStreamFlutterApi {
  final LiveStreamHostApi liveStreamHostApi = LiveStreamHostApi();
  final CameraProviderHostApi cameraProviderHostApi = CameraProviderHostApi();

  late ApiVideoLiveStreamEventsListener? _eventsListener;

  ApiVideoMessengerLiveStreamPlatform() {
    LiveStreamFlutterApi.setUp(this);
  }

  /// Registers this class as the default instance of [PathProviderPlatform].
  static void registerWith() {
    ApiVideoLiveStreamPlatform.instance = ApiVideoMessengerLiveStreamPlatform();
  }

  @override
  Future<List<CameraInfo>> getAvailableCameraInfos() async {
    final cameraIds = await cameraProviderHostApi.getAvailableCameraIds();
    final cameraInfoBuilders =
        cameraIds.map((id) => MessengerCameraInfoBuilder(id)).toList();

    return Future.wait(cameraInfoBuilders.map((builder) => builder.create()));
  }

  @override
  Future<int?> initialize() async {
    return liveStreamHostApi.create();
  }

  @override
  Future<void> dispose() {
    return liveStreamHostApi.dispose();
  }

  @override
  Future<void> setVideoConfig(VideoConfig videoConfig) {
    return liveStreamHostApi.setVideoConfig(videoConfig.toNative());
  }

  @override
  Future<void> setAudioConfig(AudioConfig audioConfig) {
    return liveStreamHostApi.setAudioConfig(audioConfig.toNative());
  }

  @override
  Future<void> startStreaming(
      {required String streamKey, required String url}) {
    return liveStreamHostApi.startStreaming(streamKey: streamKey, url: url);
  }

  @override
  Future<void> stopStreaming() {
    return liveStreamHostApi.stopStreaming();
  }

  @override
  Future<void> startPreview() {
    return liveStreamHostApi.startPreview();
  }

  @override
  Future<void> stopPreview() {
    return liveStreamHostApi.stopPreview();
  }

  @override
  Future<bool> getIsStreaming() async {
    return liveStreamHostApi.getIsStreaming();
  }

  @override
  Future<String> getCameraId() async {
    return liveStreamHostApi.getCameraId();
  }

  @override
  Future<void> setCameraId(String cameraId) {
    return liveStreamHostApi.setCameraId(cameraId);
  }

  @override
  Future<CameraInfo> getCameraInfo() async {
    final cameraId = await getCameraId();
    return MessengerCameraInfoBuilder(cameraId).create();
  }

  @override
  Future<CameraSettings> getCameraSettings() {
    return Future.value(MessengerCameraSettings.detached());
  }

  @override
  Future<void> setIsMuted(bool isMuted) {
    return liveStreamHostApi.setIsMuted(isMuted);
  }

  @override
  Future<bool> getIsMuted() async {
    return liveStreamHostApi.getIsMuted();
  }

  @override
  Future<Size?> getVideoSize() async {
    final resolution = await liveStreamHostApi.getVideoResolution();
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
    _eventsListener?.onConnectionFailed(message);
  }

  @override
  void onIsConnectedChanged(bool isConnected) {
    if (isConnected) {
      _eventsListener?.onConnectionSuccess();
    } else {
      _eventsListener?.onDisconnection();
    }
  }

  @override
  void onVideoSizeChanged(NativeResolution resolution) {
    _eventsListener?.onVideoSizeChanged(resolution.toSize());
  }

  @override
  void onError(String code, String message) {
    _eventsListener?.onError(PlatformException(code: code, message: message));
  }
}
