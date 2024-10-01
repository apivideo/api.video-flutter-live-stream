// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoConfig _$VideoConfigFromJson(Map<String, dynamic> json) => VideoConfig(
      resolution: json['resolution'] == null
          ? defaultResolution
          : const SizeConverter().fromJson(json['resolution'] as Map),
      fps: (json['fps'] as num?)?.toInt() ?? 30,
      gopDuration: json['gopDuration'] == null
          ? defaultGopDuration
          : Duration(microseconds: (json['gopDuration'] as num).toInt()),
    );

Map<String, dynamic> _$VideoConfigToJson(VideoConfig instance) =>
    <String, dynamic>{
      'resolution': const SizeConverter().toJson(instance.resolution),
      'fps': instance.fps,
      'gopDuration': instance.gopDuration.inMicroseconds,
    };
