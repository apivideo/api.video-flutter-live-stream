import 'package:apivideo_live_stream_platform_interface/src/events/listeners.dart';
import 'package:apivideo_live_stream_platform_interface/src/platform_interface/live_stream_platform_interface.dart';
import 'package:apivideo_live_stream_platform_interface/src/types/camera_position.dart';
import 'package:apivideo_live_stream_platform_interface/src/types/types.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class ApiVideoLiveStreamMethodChannel
    extends ApiVideoLiveStreamPlatformInterface {
  final MethodChannel _channel =
      const MethodChannel('video.api.livestream/controller');

  /// Registers this class as the default instance of [PathProviderPlatform].
  static void registerWith() {
    ApiVideoLiveStreamPlatformInterface.instance =
        ApiVideoLiveStreamMethodChannel();
  }

  @override
  Future<int?> initialize() async {
    final Map<String, dynamic>? reply =
        await _channel.invokeMapMethod<String, dynamic>('create');
    return reply!['textureId']! as int;
  }

  @override
  Future<void> dispose() {
    return _channel.invokeMapMethod<String, dynamic>('dispose');
  }

  @override
  Future<void> setVideoConfig(VideoConfig videoConfig) {
    return _channel.invokeMethod('setVideoConfig', videoConfig.toJson());
  }

  @override
  Future<void> setAudioConfig(AudioConfig audioConfig) {
    return _channel.invokeMethod('setAudioConfig', audioConfig.toJson());
  }

  @override
  Future<void> startStreaming(
      {required String streamKey, required String url}) {
    return _channel.invokeMethod('startStreaming', <String, dynamic>{
      'streamKey': streamKey,
      'url': url,
    });
  }

  @override
  Future<void> stopStreaming() {
    return _channel.invokeMethod('stopStreaming');
  }

  @override
  Future<void> startPreview() {
    return _channel.invokeMethod('startPreview');
  }

  @override
  Future<void> stopPreview() {
    return _channel.invokeMethod('stopPreview');
  }

  @override
  Future<bool> getIsStreaming() async {
    final Map<dynamic, dynamic> reply =
        await _channel.invokeMethod('getIsStreaming') as Map;
    return reply['isStreaming'] as bool;
  }

  @override
  Future<void> setCameraPosition(CameraPosition cameraPosition) {
    return _channel.invokeMethod('setCameraPosition',
        <String, dynamic>{'position': cameraPosition.toJson()});
  }

  @override
  Future<CameraPosition> getCameraPosition() async {
    final Map<dynamic, dynamic> reply =
        await _channel.invokeMethod('getCameraPosition') as Map;
    return CameraPosition.fromJson(reply['position'] as String);
  }

  @override
  Future<void> setIsMuted(bool isMuted) {
    return _channel
        .invokeMethod('setIsMuted', <String, dynamic>{'isMuted': isMuted});
  }

  @override
  Future<bool> getIsMuted() async {
    final Map<dynamic, dynamic> reply =
        await _channel.invokeMethod('getIsMuted') as Map;
    return reply['isMuted'] as bool;
  }

  @override
  Future<Size?> getVideoSize() async {
    final Map<dynamic, dynamic> reply =
        await _channel.invokeMethod('getVideoSize') as Map;
    if (reply.containsKey("width") && reply.containsKey("height")) {
      return Size(reply["width"] as double, reply["height"] as double);
    } else {
      return null;
    }
  }

  /// Builds the preview widget.
  @override
  Widget buildPreview(int textureId) {
    return Texture(textureId: textureId);
  }

  /// Returns a Stream of [LiveStreamingEvent]s.
  @override
  void setListener(ApiVideoLiveStreamEventsListener? listener) {
    throw UnimplementedError('setListener() has not been implemented.');
  }
}
