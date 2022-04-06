import 'dart:async';

import 'package:apivideo_live_stream/src/types/resolution.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

import 'src/types/audio_parameters.dart';
import 'src/types/video_parameters.dart';

export 'src/types.dart';

/// Controller of the live streaming
class LiveStreamController {
  static const MethodChannel _channel =
      const MethodChannel('video.api.livestream/controller');

  /// Get notified when the connection is successful
  final Function()? onConnectionSuccess;

  /// Get notified when the connection failed
  final Function(String)? onConnectionFailed;

  /// Get notified when the device has been disconnected
  final Function()? onDisconnection;

  /// [true] if the controller is streaming
  bool isStreaming = false;
  late int _textureId;
  double _aspectRatio = 0.0;

  /// Creates a new [LiveStreamController] instance.
  LiveStreamController({
    this.onConnectionSuccess,
    this.onConnectionFailed,
    this.onDisconnection,
  }) {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  /// Create a new live stream instance with initial audio and video parameters.
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
    _textureId = reply!['textureId']! as int;
    return _textureId;
  }

  /// Sets new video parameters.
  ///
  /// Do not call when in live or when preview is running.
  Future<void> setVideoParameters(VideoParameters videoParameters) {
    _aspectRatio = videoParameters.resolution.getAspectRatio();

    return _channel.invokeMethod(
        'setVideoParameters', videoParameters.toJson());
  }

  /// Sets new audio parameters.
  ///
  /// Do not call when in live or when preview is running.
  Future<void> setAudioParameters(AudioParameters audioParameters) {
    return _channel.invokeMethod(
        'setAudioParameters', audioParameters.toJson());
  }

  /// Starts the live stream to the specified "[url]/[streamKey]".
  Future<void> startStreaming(
      {required String streamKey,
      String url = "rtmp://broadcast.api.video/s/"}) async {
    try {
      await _channel.invokeMethod('startStreaming', <String, dynamic>{
        'streamKey': streamKey,
        'url': url,
      });
      isStreaming = true;
    } on PlatformException catch (e) {
      throw e;
    }
  }

  /// Stops the live stream.
  void stopStreaming() {
    _channel.invokeMethod('stopStreaming');
    isStreaming = false;
  }

  /// Starts the camera preview.
  ///
  /// The purpose of this method is to be called when application is sent
  /// to foreground.
  Future<void> startPreview() {
    return _channel.invokeMethod('startPreview');
  }

  /// Stops the camera preview.
  ///
  /// The purpose of this method is to be called when application is sent
  /// to background.
  void stopPreview() {
    _channel.invokeMethod('stopPreview');
  }

  /// Same as [stopStreaming] and [stopPreview]
  void stop() {
    stopStreaming();
    stopPreview();
  }

  /// Changes current back/front camera to front/back camera
  void switchCamera() {
    _channel.invokeMethod('switchCamera');
  }

  /// Mutes/unmutes the microphone
  void toggleMute() {
    _channel.invokeMethod('toggleMute');
  }

  Widget _buildPreview() {
    return Texture(textureId: _textureId);
  }

  Future<void> _methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case "onConnectionSuccess":
        if (onConnectionSuccess != null) {
          onConnectionSuccess!();
        }
        break;
      case "onConnectionFailed":
        isStreaming = false;
        if (onConnectionFailed != null) {
          String error = call.arguments;
          onConnectionFailed!("$error");
        }
        break;
      case "onDisconnect":
        isStreaming = false;
        if (onDisconnection != null) {
          onDisconnection!();
        }
        break;
    }
  }
}

/// Widget that displays the camera preview of [controller].
class CameraPreview extends StatelessWidget {
  final LiveStreamController controller;

  /// A widget to overlay on top of the camera preview
  final Widget? child;

  /// Creates a new [CameraPreview] instance for [controller] and a [child] overlay.
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
            _wrapInRotatedBox(
                orientation: orientation, child: controller._buildPreview()),
            child ?? Container(),
          ],
        ),
      );
    });
  }

  Widget _wrapInRotatedBox(
      {required NativeDeviceOrientation orientation, required Widget child}) {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return child;
    }

    return RotatedBox(
      quarterTurns: _getQuarterTurns(orientation),
      child: child,
    );
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
