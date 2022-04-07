// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AudioConfig _$AudioConfigFromJson(Map<String, dynamic> json) => AudioConfig(
      bitrate: json['bitrate'] as int,
      channel: $enumDecode(_$ChannelEnumMap, json['channel']),
      sampleRate: $enumDecode(_$SampleRateEnumMap, json['sampleRate']),
      enableEchoCanceler: json['enableEchoCanceler'] as bool? ?? true,
      enableNoiseSuppressor: json['enableNoiseSuppressor'] as bool? ?? true,
    );

Map<String, dynamic> _$AudioConfigToJson(AudioConfig instance) =>
    <String, dynamic>{
      'bitrate': instance.bitrate,
      'channel': _$ChannelEnumMap[instance.channel],
      'sampleRate': _$SampleRateEnumMap[instance.sampleRate],
      'enableEchoCanceler': instance.enableEchoCanceler,
      'enableNoiseSuppressor': instance.enableNoiseSuppressor,
    };

const _$ChannelEnumMap = {
  Channel.stereo: 'stereo',
  Channel.mono: 'mono',
};

const _$SampleRateEnumMap = {
  SampleRate.kHz_11: 11025,
  SampleRate.kHz_22: 22050,
  SampleRate.kHz_44_1: 44100,
};
