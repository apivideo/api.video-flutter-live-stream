import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apivideo_live_stream/apivideo_live_stream.dart';

void main() {
  const MethodChannel channel = MethodChannel('apivideolivestream');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await Apivideolivestream.platformVersion, '42');
  });
}
