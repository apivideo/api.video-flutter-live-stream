import 'package:apivideo_live_stream/apivideo_live_stream.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// The mocked method channel
  const MethodChannel channel =
      MethodChannel("video.api.livestream/controller");

  /// The platform to test
  final _platform = ApiVideoMobileLiveStreamPlatform();

  test('startStreaming', () async {
    final url = "rtmp://test";
    final streamKey = "abcde";
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      expect(methodCall.method, "startStreaming");
      expect(methodCall.arguments["url"], url);
      expect(methodCall.arguments["streamKey"], streamKey);
      return;
    });
    _platform.startStreaming(streamKey: streamKey, url: url);
    channel.setMockMethodCallHandler(null);
  });

  test('startStreaming with exception', () async {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      throw Exception();
    });

    expect(_platform.startStreaming(streamKey: "streamKey", url: "url"),
        throwsException);
    channel.setMockMethodCallHandler(null);
  });
}
