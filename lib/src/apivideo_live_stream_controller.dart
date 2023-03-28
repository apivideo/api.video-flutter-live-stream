import 'dart:async';

import 'package:apivideo_live_stream/apivideo_live_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'apivideo_live_stream_platform_interface.dart';
import 'types.dart';

ApiVideoLiveStreamPlatform get _platform {
  return ApiVideoLiveStreamPlatform.instance;
}

/// Controller of the live streaming
class ApiVideoLiveStreamController {
  final VideoConfig _initialVideoConfig;
  final AudioConfig _initialAudioConfig;
  final CameraPosition _initialCameraPosition;

  static const int kUninitializedTextureId = -1;
  int _textureId = kUninitializedTextureId;

  /// This is just exposed for testing. Do not use it.
  @internal
  int get textureId => _textureId;

  bool _isInitialized = false;

  /// Gets the current state of the video player.
  bool get isInitialized => _isInitialized;

  /// Events
  StreamSubscription<dynamic>? _eventSubscription;
  List<ApiVideoLiveStreamEventsListener> _eventsListeners = [];
  List<ApiVideoLiveStreamWidgetListener> _widgetListeners = [];

  /// Creates a new [ApiVideoLiveStreamController] instance.
  ApiVideoLiveStreamController(
      {required AudioConfig initialAudioConfig,
      required VideoConfig initialVideoConfig,
      CameraPosition initialCameraPosition = CameraPosition.back,
      VoidCallback? onConnectionSuccess,
      Function(String)? onConnectionFailed,
      VoidCallback? onDisconnection,
      Function(Exception)? onError})
      : _initialVideoConfig = initialVideoConfig,
        _initialAudioConfig = initialAudioConfig,
        _initialCameraPosition = initialCameraPosition {
    _eventsListeners.add(ApiVideoLiveStreamEventsListener(
        onConnectionSuccess: onConnectionSuccess,
        onConnectionFailed: onConnectionFailed,
        onDisconnection: onDisconnection,
        onError: onError));
  }

  ApiVideoLiveStreamController.fromListener(
      {required AudioConfig initialAudioConfig,
      required VideoConfig initialVideoConfig,
      CameraPosition initialCameraPosition = CameraPosition.back,
      ApiVideoLiveStreamEventsListener? listener})
      : _initialVideoConfig = initialVideoConfig,
        _initialAudioConfig = initialAudioConfig,
        _initialCameraPosition = initialCameraPosition {
    if (listener != null) {
      _eventsListeners.add(listener);
    }
  }

  /// Creates a new live stream instance with initial audio and video configurations.
  Future<void> initialize() async {
    _textureId = await _platform.initialize() ?? kUninitializedTextureId;

    _eventSubscription = _platform
        .liveStreamingEventsFor(_textureId)
        .listen(_eventListener, onError: _errorListener);

    for (var listener in [..._widgetListeners]) {
      if (listener.onTextureReady != null) {
        listener.onTextureReady!();
      }
    }

    await setCameraPosition(_initialCameraPosition);
    await setVideoConfig(_initialVideoConfig);
    await setAudioConfig(_initialAudioConfig);

    await startPreview();
    _isInitialized = true;
    return;
  }

  /// Disposes the live stream instance.
  Future<void> dispose() async {
    await _eventSubscription?.cancel();
    _eventsListeners.clear();
    _widgetListeners.clear();
    await _platform.dispose();
    return;
  }

  /// Sets new video parameters.
  ///
  /// Do not call when in live or when preview is running.
  Future<void> setVideoConfig(VideoConfig videoConfig) {
    return _platform.setVideoConfig(videoConfig);
  }

  /// Sets new audio parameters.
  ///
  /// Do not call when in live or when preview is running.
  Future<void> setAudioConfig(AudioConfig audioConfig) {
    return _platform.setAudioConfig(audioConfig);
  }

  /// Starts the live stream to the specified "[url]/[streamKey]".
  Future<void> startStreaming(
      {required String streamKey,
      String url = "rtmp://broadcast.api.video/s/"}) async {
    return _platform.startStreaming(streamKey: streamKey, url: url);
  }

  /// Stops the live stream.
  Future<void> stopStreaming() {
    return _platform.stopStreaming();
  }

  /// Starts the camera preview.
  ///
  /// The purpose of this method is to be called when application is sent
  /// to foreground.
  Future<void> startPreview() {
    return _platform.startPreview();
  }

  /// Stops the camera preview.
  ///
  /// The purpose of this method is to be called when application is sent
  /// to background.
  Future<void> stopPreview() {
    return _platform.stopPreview();
  }

  /// Same as [stopStreaming] and [stopPreview]
  void stop() {
    stopStreaming();
    stopPreview();
  }

  /// Gets if live stream is streaming or not.
  Future<bool> get isStreaming {
    return _platform.getIsStreaming();
  }

  /// Changes current back/front camera to front/back camera
  Future<void> switchCamera() async {
    final cameraPosition = await this.cameraPosition;
    if (cameraPosition == CameraPosition.back) {
      return setCameraPosition(CameraPosition.front);
    } else {
      return setCameraPosition(CameraPosition.back);
    }
  }

  /// Gets the current camera position
  Future<CameraPosition> get cameraPosition {
    return _platform.getCameraPosition();
  }

  /// Sets the current camera position
  Future<void> setCameraPosition(CameraPosition position) {
    return _platform.setCameraPosition(position);
  }

  /// Toggle mutes/unmutes from the microphone. See [isMuted] and [setIsMuted].
  Future<void> toggleMute() async {
    final isMuted = await this.isMuted;
    await setIsMuted(!isMuted);
  }

  /// Gets if live stream is muted or not.
  Future<bool> get isMuted {
    return _platform.getIsMuted();
  }

  /// Mutes/unmutes the microphone.
  Future<void> setIsMuted(bool isMuted) {
    return _platform.setIsMuted(isMuted);
  }

  Future<Size?> get videoSize {
    return _platform.getVideoSize();
  }

  /// Builds the preview widget.
  @internal
  Widget buildPreview() {
    return Texture(textureId: textureId);
  }

  void addEventsListener(ApiVideoLiveStreamEventsListener listener) {
    _eventsListeners.add(listener);
  }

  void removeEventsListener(ApiVideoLiveStreamEventsListener listener) {
    _eventsListeners.remove(listener);
  }

  /// This is exposed for internal use only. Do not use it.
  @internal
  void addWidgetListener(ApiVideoLiveStreamWidgetListener listener) {
    _widgetListeners.add(listener);
  }

  /// This is exposed for internal use only. Do not use it.
  @internal
  void removeWidgetListener(ApiVideoLiveStreamWidgetListener listener) {
    _widgetListeners.remove(listener);
  }

  void _errorListener(Object obj) {
    final PlatformException e = obj as PlatformException;
    for (var listener in [..._eventsListeners]) {
      if (listener.onError != null) {
        listener.onError!(e);
      }
    }
  }

  void _eventListener(LiveStreamingEvent event) {
    switch (event.type) {
      case LiveStreamingEventType.connected:
        for (var listener in [..._eventsListeners]) {
          if (listener.onConnectionSuccess != null) {
            listener.onConnectionSuccess!();
          }
        }
        break;
      case LiveStreamingEventType.disconnected:
        for (var listener in [..._eventsListeners]) {
          if (listener.onDisconnection != null) {
            listener.onDisconnection!();
          }
        }
        break;
      case LiveStreamingEventType.connectionFailed:
        for (var listener in [..._eventsListeners]) {
          if (listener.onConnectionFailed != null) {
            listener.onConnectionFailed!(event.data as String);
          }
        }
        break;
      case LiveStreamingEventType.videoSizeChanged:
        for (var listener in [..._eventsListeners]) {
          if (listener.onVideoSizeChanged != null) {
            listener.onVideoSizeChanged!(event.data as Size);
          }
        }
        break;
      case LiveStreamingEventType.unknown:
        // Nothing to do
        break;
    }
  }
}

class ApiVideoLiveStreamEventsListener {
  /// Gets notified when the connection is successful
  final VoidCallback? onConnectionSuccess;

  /// Gets notified when the connection failed
  final Function(String)? onConnectionFailed;

  /// Gets notified when the device has been disconnected
  final VoidCallback? onDisconnection;

  /// Gets notified when the video size has changed. Mostly designed to update Widget aspect ratio.
  final Function(Size)? onVideoSizeChanged;

  /// Gets notified when an error occurs
  final Function(Exception)? onError;

  ApiVideoLiveStreamEventsListener(
      {this.onConnectionSuccess,
      this.onConnectionFailed,
      this.onDisconnection,
      this.onVideoSizeChanged,
      this.onError});
}

class ApiVideoLiveStreamWidgetListener {
  final VoidCallback? onTextureReady;

  ApiVideoLiveStreamWidgetListener({this.onTextureReady});
}
