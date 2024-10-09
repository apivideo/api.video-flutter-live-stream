import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
      dartOut: 'lib/src/platform/generated/live_stream_api.g.dart',
      kotlinOut:
          'android/src/main/kotlin/video/api/flutter/livestream/generated/GeneratedLiveStreamApi.g.kt',
      kotlinOptions:
          KotlinOptions(package: 'video.api.flutter.livestream.generated'),
      swiftOut: 'ios/Classes/Generated/GeneratedLiveStreamApi.g.swift'),
)
class NativeResolution {
  const NativeResolution({
    required this.width,
    required this.height,
  });

  final int width;
  final int height;
}

/// Audio channel
enum NativeChannel {
  /// Stereo (2 channels)
  stereo,

  /// Mono (1 channel)
  mono,
}

/// Live streaming audio configuration.
class NativeAudioConfig {
  /// Creates a new [AudioConfig] instance.
  ///
  /// [sampleRate] is only supported on Android.
  /// [channel] is only supported on Android.
  const NativeAudioConfig(this.bitrate, this.channel, this.sampleRate,
      this.enableEchoCanceler, this.enableNoiseSuppressor);

  /// The video bitrate in bps
  final int bitrate;

  /// The number of audio channels
  /// Only available on Android
  final NativeChannel channel;

  /// The sample rate of the audio capture
  /// Only available on Android
  /// Example: 44100, 48000, 96000
  /// For RTMP sample rate, only 11025, 22050, 44100 are supported
  final int sampleRate;

  /// Enable the echo cancellation
  /// Only available on Android
  final bool enableEchoCanceler;

  /// Enable the noise suppressor
  /// Only available on Android
  final bool enableNoiseSuppressor;
}

/// Live streaming video configuration.
class NativeVideoConfig {
  /// Creates a [VideoConfig] instance
  const NativeVideoConfig(
      this.bitrate, this.resolution, this.fps, this.gopDurationInS);

  /// The video bitrate in bps
  final int bitrate;

  /// The live streaming video resolution
  final NativeResolution resolution;

  /// The video frame rate in fps
  final int fps;

  /// GOP (Group of Pictures) duration in seconds
  final double gopDurationInS;
}

/// Camera facing direction
enum NativeCameraLensDirection {
  /// Front camera
  front,

  /// Back camera
  back,

  /// Other camera (external for example)
  other;
}

// From Flutter to native
@HostApi()
abstract class LiveStreamHostApi {
  int create();

  void dispose();

  @async
  void setVideoConfig(NativeVideoConfig videoConfig);

  @async
  void setAudioConfig(NativeAudioConfig audioConfig);

  void startStreaming({required String streamKey, required String url});

  void stopStreaming();

  @async
  void startPreview();

  void stopPreview();

  bool getIsStreaming();

  String getCameraId();

  @async
  void setCameraId(String cameraId);

  bool getIsMuted();

  void setIsMuted(bool isMuted);

  NativeResolution? getVideoResolution();
}

// From native to Flutter
@FlutterApi()
abstract class LiveStreamFlutterApi {
  void onIsConnectedChanged(bool isConnected);

  void onConnectionFailed(String message);

  void onVideoSizeChanged(NativeResolution resolution);

  void onError(String code, String message);
}

@HostApi()
abstract class CameraInfoHostApi {
  int getSensorRotationDegrees(String cameraId);

  NativeCameraLensDirection getLensDirection(String cameraId);

  double getMinZoomRatio(String cameraId);

  double getMaxZoomRatio(String cameraId);
}

@HostApi()
abstract class CameraSettingsHostApi {
  void setZoomRatio(double zoomRatio);

  double getZoomRatio();
}

@HostApi()
abstract class CameraProviderHostApi {
  List<String> getAvailableCameraIds();
}
