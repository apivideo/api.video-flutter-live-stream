// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_parameters.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoParameters _$VideoParametersFromJson(Map<String, dynamic> json) =>
    VideoParameters(
      bitrate: json['bitrate'] as int,
      resolution: $enumDecode(_$ResolutionEnumMap, json['resolution']),
      fps: json['fps'] as int,
    );

Map<String, dynamic> _$VideoParametersToJson(VideoParameters instance) =>
    <String, dynamic>{
      'bitrate': instance.bitrate,
      'resolution': _$ResolutionEnumMap[instance.resolution],
      'fps': instance.fps,
    };

const _$ResolutionEnumMap = {
  Resolution.RESOLUTION_240: '240p',
  Resolution.RESOLUTION_360: '360p',
  Resolution.RESOLUTION_480: '480p',
  Resolution.RESOLUTION_720: '720p',
  Resolution.RESOLUTION_1080: '1080',
  Resolution.RESOLUTION_2160: '2160p',
};
