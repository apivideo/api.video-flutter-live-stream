import 'dart:async';

import 'package:apivideo_live_stream/apivideo_live_stream.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'listeners.dart';
import 'platform_interface/platform_interface.dart';

ApiVideoLiveStreamPlatform get _platform {
  return ApiVideoLiveStreamPlatform.instance;
}

/// Gets list of available cameras.
Future<List<CameraInfo>> getAvailableCameraInfos() async {
  return _platform.getAvailableCameraInfos();
}

/// Controller of the live streaming
class ApiVideoLiveStreamController {
  final VideoConfig _initialVideoConfig;
  final AudioConfig _initialAudioConfig;
  final String? _initialCameraId;

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
  /// If [initialCameraId] is not provided, the first back camera will be used.
  ApiVideoLiveStreamController(
      {required AudioConfig initialAudioConfig,
      required VideoConfig initialVideoConfig,
      String? initialCameraId = null})
      : _initialVideoConfig = initialVideoConfig,
        _initialAudioConfig = initialAudioConfig,
        _initialCameraId = initialCameraId {}

  /// Creates a new live stream instance with initial audio and video configurations.
  Future<void> initialize() async {
    _platform.setListener(_eventsListenersManager);
    _textureId = await _platform.initialize() ?? kUninitializedTextureId;

    for (var listener in [..._widgetListeners]) {
      listener.onTextureReady();
    }

    if (_initialCameraId == null) {
      final cameraInfos = await getAvailableCameraInfos();
      final cameraInfo = cameraInfos.firstWhere((cameraInfo) {
        return cameraInfo.lensDirection == CameraLensDirection.back;
      });
      await setCameraInfo(cameraInfo);
    } else {
      await setCameraId(_initialCameraId!);
    }
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

  /// Toggle current back/front camera to front/back camera
  Future<void> toggleCamera() async {
    final cameraPosition = (await this.camera).lensDirection;
    if (cameraPosition == CameraLensDirection.back) {
      return setCameraLensDirection(CameraLensDirection.front);
    } else {
      return setCameraLensDirection(CameraLensDirection.back);
    }
  }

  /// Sets the current camera from its [lensDirection]
  Future<void> setCameraLensDirection(CameraLensDirection lensDirection) async {
    final camera = await getAvailableCameraInfos().then((cameras) {
      return cameras
          .firstWhere((camera) => camera.lensDirection == lensDirection);
    });
    return _platform.setCameraId(camera.id);
  }

  /// Sets the current camera from its [cameraId]
  Future<void> setCameraId(String cameraId) {
    return _platform.setCameraId(cameraId);
  }

  /// Sets the current camera from its [cameraInfo]
  Future<void> setCameraInfo(CameraInfo cameraInfo) {
    return setCameraId(cameraInfo.id);
  }

  /// Gets the current camera and its information.
  Future<CameraInfo> get camera async {
    return _platform.getCameraInfo();
  }

  /// Gets the current camera settings.
  Future<CameraSettings> get cameraSettings {
    return _platform.getCameraSettings();
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

  /// Gets the current video [Size].
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
