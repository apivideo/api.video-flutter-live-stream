// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoConfig _$VideoConfigFromJson(Map<String, dynamic> json) => VideoConfig(
      bitrate: json['bitrate'] as int,
      resolution:
          $enumDecodeNullable(_$ResolutionEnumMap, json['resolution']) ??
              Resolution.RESOLUTION_720,
      fps: json['fps'] as int? ?? 30,
    );

Map<String, dynamic> _$VideoConfigToJson(VideoConfig instance) =>
    <String, dynamic>{
      'bitrate': instance.bitrate,
      'resolution': _$ResolutionEnumMap[instance.resolution]!,
      'fps': instance.fps,
    };

const _$ResolutionEnumMap = {
  Resolution.RESOLUTION_240: '240p',
  Resolution.RESOLUTION_360: '360p',
  Resolution.RESOLUTION_480: '480p',
  Resolution.RESOLUTION_720: '720p',
  Resolution.RESOLUTION_1080: '1080p',
};
