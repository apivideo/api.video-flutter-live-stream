import 'package:json_annotation/json_annotation.dart';

/// Enumeration for camera resolution
enum Resolution {
  /// 352x240
  @JsonValue("240p")
  RESOLUTION_240,

  /// 640x360
  @JsonValue("360p")
  RESOLUTION_360,

  /// 858x480
  @JsonValue("480p")
  RESOLUTION_480,

  /// 1280x720
  @JsonValue("720p")
  RESOLUTION_720,

  /// 1920x1080
  @JsonValue("1080p")
  RESOLUTION_1080
}

/// Extension of [Resolution]
extension ResolutionExtension on Resolution {
  /// Returns the aspect ratio from a [Resolution]
  double getAspectRatio() {
    var result = 0.0;
    switch (this) {
      case Resolution.RESOLUTION_240:
        result = 352 / 240;
        break;
      case Resolution.RESOLUTION_360:
        result = 640 / 360;
        break;
      case Resolution.RESOLUTION_480:
        result = 858 / 480;
        break;
      case Resolution.RESOLUTION_720:
        result = 1280 / 720;
        break;
      case Resolution.RESOLUTION_1080:
        result = 1920 / 1080;
        break;
      default:
        result = 16 / 9;
        break;
    }
    return result;
  }
}
