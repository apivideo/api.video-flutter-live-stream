import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'apivideo_live_stream_platform_interface.dart';
import 'types.dart';

/// Controller of the live streaming
class ApiVideoMobileLiveStreamPlatform extends ApiVideoLiveStreamPlatform {
  final MethodChannel _channel =
      const MethodChannel('video.api.livestream/controller');

  /// Registers this class as the default instance of [PathProviderPlatform].
  static void registerWith() {
    ApiVideoLiveStreamPlatform.instance = ApiVideoMobileLiveStreamPlatform();
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

  @override
  Stream<LiveStreamingEvent> liveStreamingEventsFor(int textureId) {
    return EventChannel('video.api.livestream/events')
        .receiveBroadcastStream()
        .map((dynamic map) {
      final Map<dynamic, dynamic> event = map as Map<dynamic, dynamic>;
      switch (event['type']) {
        case 'connected':
          return LiveStreamingEvent(type: LiveStreamingEventType.connected);
        case 'disconnected':
          return LiveStreamingEvent(type: LiveStreamingEventType.disconnected);
        case 'connectionFailed':
          return LiveStreamingEvent(
              type: LiveStreamingEventType.connectionFailed,
              data: event['message']);
        case 'videoSizeChanged':
          return LiveStreamingEvent(
              type: LiveStreamingEventType.videoSizeChanged,
              data: Size(event['width'] as double, event['height'] as double));
        default:
          return LiveStreamingEvent(type: LiveStreamingEventType.unknown);
      }
    });
  }
}
