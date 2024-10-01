// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AudioConfig _$AudioConfigFromJson(Map<String, dynamic> json) => AudioConfig(
      bitrate: (json['bitrate'] as num?)?.toInt() ?? 128000,
      channel: $enumDecodeNullable(_$ChannelEnumMap, json['channel']) ??
          Channel.stereo,
      sampleRate: (json['sampleRate'] as num?)?.toInt() ?? 44100,
      enableEchoCanceler: json['enableEchoCanceler'] as bool? ?? true,
      enableNoiseSuppressor: json['enableNoiseSuppressor'] as bool? ?? true,
    );

Map<String, dynamic> _$AudioConfigToJson(AudioConfig instance) =>
    <String, dynamic>{
      'bitrate': instance.bitrate,
      'channel': _$ChannelEnumMap[instance.channel]!,
      'sampleRate': instance.sampleRate,
      'enableEchoCanceler': instance.enableEchoCanceler,
      'enableNoiseSuppressor': instance.enableNoiseSuppressor,
    };

const _$ChannelEnumMap = {
  Channel.stereo: 'stereo',
  Channel.mono: 'mono',
};
