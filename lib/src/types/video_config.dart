import 'package:json_annotation/json_annotation.dart';

import 'resolution.dart';

part 'video_config.g.dart';

/// Live streaming video configuration.
@JsonSerializable()
class VideoConfig {
  /// The video bitrate in bps
  int bitrate;

  /// The live streaming video resolution
  Resolution resolution;

  /// The video framerate in fps
  int fps;

  /// Creates a [VideoConfig] instance
  VideoConfig(
      {required this.bitrate, required this.resolution, required this.fps});

  /// Creates a [VideoConfig] from a [json] map.
  factory VideoConfig.fromJson(Map<String, dynamic> json) =>
      _$VideoConfigFromJson(json);

  /// Creates a json map from a [VideoConfig].
  Map<String, dynamic> toJson() => _$VideoConfigToJson(this);
}
