import 'package:json_annotation/json_annotation.dart';

import 'resolution.dart';

part 'video_parameters.g.dart';

@JsonSerializable()
class VideoParameters {
  int bitrate;
  Resolution resolution;
  int fps;

  VideoParameters(
      {required this.bitrate, required this.resolution, required this.fps});

  factory VideoParameters.fromJson(Map<String, dynamic> json) =>
      _$VideoParametersFromJson(json);

  Map<String, dynamic> toJson() => _$VideoParametersToJson(this);
}
