import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
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
    await _channel.invokeMethod('startStreaming');
  }

  static Future<void> stopStream() async {
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
  final String? liveStreamKey;
  final String? rtmpServerUrl;
  final int? videoFps;
  final String? videoResolution;
  final int? videoBitrate;
  final String? videoCamera;
  final String? videoOrientation;
  final bool? audioMuted;
  final int? audioBitrate;
  final Function()? onConnectionSuccess;
  final Function(String)? onConnectionError;
  final Function()? onDeconnection;

  const LiveStreamPreview({
    required this.controller,
    this.liveStreamKey,
    this.rtmpServerUrl,
    this.videoFps,
    this.videoResolution,
    this.videoBitrate,
    this.videoCamera,
    this.videoOrientation,
    this.audioMuted,
    this.audioBitrate,
    this.onConnectionSuccess,
    this.onConnectionError,
    this.onDeconnection,
  });

  @override
  _LiveStreamPreviewState createState() => _LiveStreamPreviewState();
}

class _LiveStreamPreviewState extends State<LiveStreamPreview> {
  late MethodChannel _channel;

  @override
  void initState() {
    super.initState();
  }

  _prepare(int viewId) async {
    _channel = MethodChannel('apivideolivestream_$viewId');
    _channel.setMethodCallHandler(_methodCallHandler);

    if (widget.liveStreamKey!.isNotEmpty) {
      _channel.invokeMethod('setLivestreamKey', widget.liveStreamKey);
    }
    await createParams();
  }

  createParams() {
    var param = {};
    param["liveStreamKey"] = widget.liveStreamKey;
    param["rtmpServerUrl"] =
        widget.rtmpServerUrl ?? 'rtmp://broadcast.api.video/s/';
    param["videoFps"] = widget.videoFps ?? 30;
    param["videoResolution"] = widget.videoResolution ?? '720p';
    param["videoBitrate"] = widget.videoBitrate ?? 128000;
    param["videoCamera"] = widget.videoCamera ?? "back";
    param["videoOrientation"] = widget.videoOrientation ?? 'portrait';
    param["audioMuted"] = widget.audioMuted ?? false;
    param["audioBitrate"] = widget.audioBitrate ?? -1;
    return param;
  }

  Future<void> _methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case "onConnectionSuccess":
        if (widget.onConnectionSuccess != null) {
          widget.onConnectionSuccess!();
        }
        break;
      case "onConnectionFailed":
        if (widget.onConnectionError != null) {
          String error = call.arguments;
          widget.onConnectionError!("$error");
        }
        break;
      case "onDisconnect":
        if (widget.onDeconnection != null) {
          widget.onDeconnection!();
        }
        break;

      case "setParam":
        var params = createParams();
        _channel.invokeMethod('setParam', json.encode(params));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String viewType = '<platform-view-type>';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return SizedBox(
          height: 400,
          child: AndroidView(
            viewType: viewType,
            onPlatformViewCreated: (viewId) {
              print("viewId $viewId");
              _prepare(viewId);
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
            onPlatformViewCreated: (viewId) {
              print("viewId $viewId");
              _prepare(viewId);
            },
            creationParamsCodec: const StandardMessageCodec(),
          ),
        );
      default:
        throw UnsupportedError("Unsupported platform view");
    }
  }
}
