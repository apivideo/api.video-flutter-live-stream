import 'package:apivideo_live_stream/apivideo_live_stream.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel =
      MethodChannel("video.api.livestream/controller");
  final _controller = ApiVideoLiveStreamController(
      initialVideoConfig: VideoConfig.withDefaultBitrate(),
      initialAudioConfig: AudioConfig());

  test('startStreaming', () async {
    final url = "rtmp://test";
    final streamKey = "abcde";
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      expect(methodCall.method, "startStreaming");
      expect(methodCall.arguments["url"], url);
      expect(methodCall.arguments["streamKey"], streamKey);
      return;
    });
    _controller.startStreaming(streamKey: streamKey, url: url);
    channel.setMockMethodCallHandler(null);
  });

  test('startStreaming with exception', () async {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      throw Exception();
    });

    expect(_controller.startStreaming(streamKey: "abcde"), throwsException);
    channel.setMockMethodCallHandler(null);
  });
}
