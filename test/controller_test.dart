import 'dart:async';

import 'package:apivideo_live_stream/apivideo_live_stream.dart';
import 'package:apivideo_live_stream/src/platform_interface/platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// The mocked platform
  final _mockedPlatform = MockedApiVideoLiveStreamPlatform();
  ApiVideoLiveStreamPlatform.instance = _mockedPlatform;

  /// The controller to test
  final _controller = ApiVideoLiveStreamController(
      initialVideoConfig: VideoConfig(), initialAudioConfig: AudioConfig(), initialCameraId: "test");

  test('initialized', () async {
    await _controller.initialize();
    expect(_mockedPlatform.calls.length, 6);
    expect(_mockedPlatform.calls.first, 'setListener');
    expect(_mockedPlatform.calls[1], 'initialize');
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
  Future<void> setCameraId(String cameraId) {
    calls.add('setCameraId');
    return Future.value();
  }

  @override
  void setListener(ApiVideoLiveStreamEventsListener? listener) {
    calls.add('setListener');
  }
}
