import 'package:json_annotation/json_annotation.dart';

import 'resolution.dart';

part 'video_parameters.g.dart';

/// Live streaming video parameters
@JsonSerializable()
class VideoParameters {
  /// The video bitrate in bps
  int bitrate;

  /// The live streaming video resolution
  Resolution resolution;

  /// The video framerate in fps
  int fps;

  /// Creates a [VideoParameters] instance
  VideoParameters(
      {required this.bitrate, required this.resolution, required this.fps});

  /// Creates a [VideoParameters] from a [json] map.
  factory VideoParameters.fromJson(Map<String, dynamic> json) =>
      _$VideoParametersFromJson(json);

  /// Creates a json map from a [VideoParameters].
  Map<String, dynamic> toJson() => _$VideoParametersToJson(this);
}
