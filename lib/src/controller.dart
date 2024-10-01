import 'dart:async';

import 'package:apivideo_live_stream/apivideo_live_stream.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'listeners.dart';
import 'platform/platform_interface.dart';

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

  /// Events listeners
  _EventListenersManager _eventsListenersManager = _EventListenersManager();
  List<ApiVideoLiveStreamWidgetListener> _widgetListeners = [];

  /// Creates a new [ApiVideoLiveStreamController] instance.
  ApiVideoLiveStreamController(
      {required AudioConfig initialAudioConfig,
      required VideoConfig initialVideoConfig,
      CameraPosition initialCameraPosition = CameraPosition.back})
      : _initialVideoConfig = initialVideoConfig,
        _initialAudioConfig = initialAudioConfig,
        _initialCameraPosition = initialCameraPosition {}

  /// Creates a new live stream instance with initial audio and video configurations.
  Future<void> initialize() async {
    _platform.setListener(_eventsListenersManager);
    _textureId = await _platform.initialize() ?? kUninitializedTextureId;

    for (var listener in [..._widgetListeners]) {
      listener.onTextureReady();
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
    _platform.setListener(null);
    _eventsListenersManager.dispose();
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
  Future<void> stop() async {
    await stopStreaming();
    await stopPreview();
  }

  /// Gets if live stream is streaming or not.
  Future<bool> get isStreaming {
    return _platform.getIsStreaming();
  }

  /// Changes current back/front camera to front/back camera
  Future<void> toggleCamera() async {
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

  /// Adds a new widget listener from the events listener.
  void addEventsListener(ApiVideoLiveStreamEventsListener listener) {
    _eventsListenersManager.add(listener);
  }

  /// Removes an events listener.
  void removeEventsListener(ApiVideoLiveStreamEventsListener listener) {
    _eventsListenersManager.remove(listener);
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
}

class _EventListenersManager with ApiVideoLiveStreamEventsListener {
  final List<ApiVideoLiveStreamEventsListener> listeners = [];

  void onConnectionSuccess() {
    for (var listener in listeners) {
      listener.onConnectionSuccess();
    }
  }

  void onConnectionFailed(String reason) {
    for (var listener in listeners) {
      listener.onConnectionFailed(reason);
    }
  }

  void onDisconnection() {
    for (var listener in listeners) {
      listener.onDisconnection();
    }
  }

  void onError(Exception error) {
    for (var listener in listeners) {
      listener.onError(error);
    }
  }

  void onVideoSizeChanged(Size size) {
    for (var listener in listeners) {
      listener.onVideoSizeChanged(size);
    }
  }

  void add(ApiVideoLiveStreamEventsListener listener) {
    listeners.add(listener);
  }

  void remove(ApiVideoLiveStreamEventsListener listener) {
    listeners.remove(listener);
  }

  void dispose() {
    listeners.clear();
  }
}
