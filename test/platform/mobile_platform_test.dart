import 'package:apivideo_live_stream/src/platform/mobile_platform.dart';
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
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      expect(methodCall.method, "startStreaming");
      expect(methodCall.arguments["url"], url);
      expect(methodCall.arguments["streamKey"], streamKey);
      return;
    });
    _platform.startStreaming(streamKey: streamKey, url: url);
  });

  test('startStreaming with exception', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      throw Exception();
    });

    expect(_platform.startStreaming(streamKey: "streamKey", url: "url"),
        throwsException);
  });
}
