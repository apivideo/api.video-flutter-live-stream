import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/types/audio_parameters.dart';
import 'src/types/video_parameters.dart';

export 'src/types.dart';

class LiveStreamController {
  static const MethodChannel _channel =
  const MethodChannel('video.api.livestream/controller');
  final Function()? onConnectionSuccess;
  final Function(String)? onConnectionFailed;
  final Function()? onDisconnection;

  LiveStreamController({
    this.onConnectionSuccess,
    this.onConnectionFailed,
    this.onDisconnection,
  }) {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  void setVideoParameters(VideoParameters videoParameters) {
    _channel.invokeMethod('setVideoParameters', videoParameters.toJson());
  }

  void setAudioParameters(AudioParameters audioParameters) {
    _channel.invokeMethod('setAudioParameters', audioParameters.toJson());
  }

  Future<void> startStreaming({required String streamKey,
    String url = "rtmp://broadcast.api.video/s/"}) {
    return _channel.invokeMethod('startStreaming', <String, dynamic>{
      'streamKey': streamKey,
      'url': url,
    });
  }

  void stopStreaming() {
    _channel.invokeMethod('stopStreaming');
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
  final VideoParameters initialVideoParameters;
  final AudioParameters initialAudioParameters;

  const CameraPreview({required this.controller,
    required this.initialAudioParameters,
    required this.initialVideoParameters});

  @override
  Widget build(BuildContext context) {
    final String viewType = '<platform-view-type>';
    final Map<String, dynamic> creationParams = <String, dynamic>{
      "audioParameters": initialAudioParameters.toJson(),
      "videoParameters": initialVideoParameters.toJson()
    };

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
            viewType: viewType,
            creationParamsCodec: const StandardMessageCodec(),
            creationParams: creationParams);

      case TargetPlatform.iOS:
        return UiKitView(
            viewType: viewType,
            layoutDirection: TextDirection.ltr,
            creationParamsCodec: const StandardMessageCodec(),
            creationParams: creationParams);
      default:
        throw UnsupportedError("Unsupported platform view");
    }
  }
}
