import 'dart:async';

import 'package:apivideo_live_stream/apivideo_live_stream.dart';
import 'package:apivideo_live_stream/src/apivideo_live_stream_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// The mocked platform
  final _mockedPlatform = MockedApiVideoLiveStreamPlatform();
  ApiVideoLiveStreamPlatform.instance = _mockedPlatform;

  /// The controller to test
  final _controller = ApiVideoLiveStreamController(
      initialVideoConfig: VideoConfig.withDefaultBitrate(),
      initialAudioConfig: AudioConfig());

  test('initialized', () async {
    await _controller.initialize();
    expect(_mockedPlatform.calls.length, 5);
    expect(_mockedPlatform.calls.first, 'initialize');
  });
}

class MockedApiVideoLiveStreamPlatform extends ApiVideoLiveStreamPlatform {
  Completer<bool> initialized = Completer<bool>();
  List<String> calls = <String>[];

  @override
  Future<int?> initialize() {
    calls.add('initialize');
    initialized.complete(true);
    return Future.value(0);
  }

  @override
  Future<void> startPreview() {
    calls.add('startPreview');
    return Future.value();
  }

  @override
  Future<void> setVideoConfig(VideoConfig videoConfig) {
    calls.add('setVideoConfig');
    return Future.value();
  }

  @override
  Future<void> setAudioConfig(AudioConfig audioConfig) {
    calls.add('setAudioConfig');
    return Future.value();
  }

  @override
  Future<void> setCameraPosition(CameraPosition position) {
    calls.add('setCameraPosition');
    return Future.value();
  }

  @override
  Stream<LiveStreamingEvent> liveStreamingEventsFor(int textureId) {
    return StreamController<LiveStreamingEvent>().stream;
  }
}
