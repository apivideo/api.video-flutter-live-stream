import 'dart:ui';

/// Enumeration for camera resolution
/// Only 16/9 resolutions are supported.
enum PredefinedResolution {
  /// 426x240
  RESOLUTION_240(resolution: Size(426, 240)),

  /// 640x360
  RESOLUTION_360(resolution: Size(640, 360)),

  /// 854x480
  RESOLUTION_480(resolution: Size(854, 480)),

  /// 1280x720
  RESOLUTION_720(resolution: Size(1280, 720)),

  /// 1920x1080
  RESOLUTION_1080(resolution: Size(1920, 1080));

  const PredefinedResolution({required this.resolution});

  final Size resolution;
}
