import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Apivideolivestream {
  static const MethodChannel _channel =
      const MethodChannel('apivideolivestream_0');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> startStream() async {
    print("start stream called");
    await _channel.invokeMethod('startStreaming');
  }

  static Future<void> stopStream() async {
    print("stop stream called");
    await _channel.invokeMethod('stopStreaming');
  }

  static void switchCamera() async {
    await _channel.invokeMethod('switchCamera');
  }

  static void changeMute() async {
    await _channel.invokeMethod('changeMute');
  }
}

class LiveStreamPreview extends StatefulWidget {
  final Apivideolivestream controller;
  final String liveStreamKey;
  final String? rtmpServerUrl;
  final double? videoFps;
  final String? videoResolution;
  final double? videoBitrate;
  final String? videoCamera;
  final String? videoOrientation;
  final bool? audioMuted;
  final double? audioBitrate;

  const LiveStreamPreview({
    required this.controller,
    required this.liveStreamKey,
    this.rtmpServerUrl,
    this.videoFps,
    this.videoResolution,
    this.videoBitrate,
    this.videoCamera,
    this.videoOrientation,
    this.audioMuted,
    this.audioBitrate,
  });

  @override
  _LiveStreamPreviewState createState() => _LiveStreamPreviewState();
}

class _LiveStreamPreviewState extends State<LiveStreamPreview> {
  late MethodChannel _channel;
  late Apivideolivestream _controller;
  Set _updateMap = {};

  createParams() {
    var param = {};
    param["liveStreamKey"] = widget.liveStreamKey;
    param["rtmpServerUrl"] = widget.rtmpServerUrl ?? 'rtmp://broadcast.api.video/s';
    param["videoFps"] = widget.videoFps ?? 30;
    param["videoResolution"] = widget.videoResolution ?? '720p';
    param["videoBitrate"] = widget.videoBitrate ?? -1;
    param["videoCamera"] =  widget.videoCamera ?? "back";
    param["videoOrientation"] = widget.videoOrientation ?? 'landscape';
    param["audioMuted"] = widget.audioMuted ?? false;
    param["audioBitrate"] = widget.audioBitrate ?? -1;
    return param;
  }

  @override
  void initState() {
    _controller = widget.controller;
    if (widget.liveStreamKey.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 300)).then((value) {
        _channel.invokeMethod('setLivestreamKey', widget.liveStreamKey);
      });
    }
    Future.delayed(const Duration(milliseconds: 300)).then((value) {
      _channel.invokeMethod('setParam', json.encode(createParams()));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final String viewType = '<platform-view-type>';
    // Pass parameters to the platform side.

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return SizedBox(
          height: 400,
          child: AndroidView(
            viewType: viewType,
            creationParams: createParams(),
            onPlatformViewCreated: (viewId) {
              _channel = MethodChannel('apivideolivestream_$viewId');
            },
            creationParamsCodec: const StandardMessageCodec(),
          ),
          /*  PlatformViewLink(
              viewType: viewType,
              surfaceFactory: (BuildContext context, dynamic controller) {
                return AndroidViewSurface(
                  controller: controller,
                  gestureRecognizers: const <
                      Factory<OneSequenceGestureRecognizer>>{},
                  hitTestBehavior: PlatformViewHitTestBehavior.opaque,
                );
              },
              onCreatePlatformView: (PlatformViewCreationParams params) {
                return PlatformViewsService.initSurfaceAndroidView(
                  id: params.id,
                  viewType: viewType,
                  layoutDirection: TextDirection.ltr,
                  creationParams: createParams(),
                  creationParamsCodec: StandardMessageCodec(),
                )
                  ..addOnPlatformViewCreatedListener((id) {
                    _channel = MethodChannel('apivideolivestream_$id');
                    //_channel.setMethodCallHandler(_handlerCall);
                  })
                  ..create();
              },*/
        );

      case TargetPlatform.iOS:
        return SizedBox(
          height: 400,
          child: UiKitView(
            viewType: viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: createParams(),
            onPlatformViewCreated: (viewId) {
              _channel = MethodChannel('apivideolivestream_$viewId');
            },
            creationParamsCodec: const StandardMessageCodec(),
          ),
        );
      default:
        throw UnsupportedError("Unsupported platform view");
    }
  }
}
