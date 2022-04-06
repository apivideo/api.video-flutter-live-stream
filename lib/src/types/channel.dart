import 'package:json_annotation/json_annotation.dart';

/// Audio channel
enum Channel {
  /// Stereo (2 channels)
  @JsonValue("stereo")
  stereo,

  /// Mono (1 channel)
  @JsonValue("mono")
  mono,
}
