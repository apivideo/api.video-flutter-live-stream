import 'dart:async';

import 'package:apivideo_live_stream/src/types/resolution.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

import 'src/types/audio_parameters.dart';
import 'src/types/video_parameters.dart';

export 'src/types.dart';

class LiveStreamController {
  static const MethodChannel _channel =
      const MethodChannel('video.api.livestream/controller');
  final Function()? onConnectionSuccess;
  final Function(String)? onConnectionFailed;
  final Function()? onDisconnection;
  late int textureId;
  double _aspectRatio = 0.0;

  LiveStreamController({
    this.onConnectionSuccess,
    this.onConnectionFailed,
    this.onDisconnection,
  }) {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  Future<int> create(
      {required AudioParameters initialAudioParameters,
      required VideoParameters initialVideoParameters}) async {
    final Map<String, dynamic> creationParams = <String, dynamic>{
      "audioParameters": initialAudioParameters.toJson(),
      "videoParameters": initialVideoParameters.toJson()
    };

    _aspectRatio = initialVideoParameters.resolution.getAspectRatio();

    final Map<String, dynamic>? reply = await _channel
        .invokeMapMethod<String, dynamic>('create', creationParams);
    textureId = reply!['textureId']! as int;
    return textureId;
  }

  Future<void> setVideoParameters(VideoParameters videoParameters) {
    _aspectRatio = videoParameters.resolution.getAspectRatio();

    return _channel.invokeMethod(
        'setVideoParameters', videoParameters.toJson());
  }

  Future<void> setAudioParameters(AudioParameters audioParameters) {
    return _channel.invokeMethod(
        'setAudioParameters', audioParameters.toJson());
  }

  Future<void> startStreaming(
      {required String streamKey,
      String url = "rtmp://broadcast.api.video/s/"}) {
    return _channel.invokeMethod('startStreaming', <String, dynamic>{
      'streamKey': streamKey,
      'url': url,
    });
  }

  void stopStreaming() {
    _channel.invokeMethod('stopStreaming');
  }

  Future<void> startPreview() {
    return _channel.invokeMethod('startPreview');
  }

  void stopPreview() {
    _channel.invokeMethod('stopPreview');
  }

  void stop() {
    stopStreaming();
    stopPreview();
  }

  void switchCamera() {
    _channel.invokeMethod('switchCamera');
  }

  void toggleMute() {
    _channel.invokeMethod('toggleMute');
  }

  Future<void> _methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case "onConnectionSuccess":
        if (onConnectionSuccess != null) {
          onConnectionSuccess!();
        }
        break;
      case "onConnectionFailed":
        if (onConnectionFailed != null) {
          String error = call.arguments;
          onConnectionFailed!("$error");
        }
        break;
      case "onDisconnect":
        if (onDisconnection != null) {
          onDisconnection!();
        }
        break;
    }
  }
}

class CameraPreview extends StatelessWidget {
  final LiveStreamController controller;

  /// A widget to overlay on top of the camera preview
  final Widget? child;

  CameraPreview({required this.controller, this.child});

  @override
  Widget build(BuildContext context) {
    return NativeDeviceOrientationReader(builder: (context) {
      final orientation = NativeDeviceOrientationReader.orientation(context);
      return AspectRatio(
        aspectRatio: _isLandscape(orientation)
            ? controller._aspectRatio
            : 1 / controller._aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            RotatedBox(
                quarterTurns: _getQuarterTurns(orientation),
                child: Texture(textureId: controller.textureId)),
            child ?? Container(),
          ],
        ),
      );
    });
  }

  bool _isLandscape(NativeDeviceOrientation orientation) {
    return [
      NativeDeviceOrientation.landscapeLeft,
      NativeDeviceOrientation.landscapeRight
    ].contains(orientation);
  }

  int _getQuarterTurns(NativeDeviceOrientation orientation) {
    Map<NativeDeviceOrientation, int> turns = {
      NativeDeviceOrientation.unknown: 0,
      NativeDeviceOrientation.portraitUp: 0,
      NativeDeviceOrientation.landscapeRight: 1,
      NativeDeviceOrientation.portraitDown: 2,
      NativeDeviceOrientation.landscapeLeft: 3,
    };
    return turns[orientation]!;
  }
}
