// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_parameters.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AudioParameters _$AudioParametersFromJson(Map<String, dynamic> json) =>
    AudioParameters(
      bitrate: json['bitrate'] as int,
      channel: $enumDecode(_$ChannelEnumMap, json['channel']),
      sampleRate: $enumDecode(_$SampleRateEnumMap, json['sampleRate']),
      enableEchoCanceler: json['enableEchoCanceler'] as bool? ?? true,
      enableNoiseSuppressor: json['enableNoiseSuppressor'] as bool? ?? true,
    );

Map<String, dynamic> _$AudioParametersToJson(AudioParameters instance) =>
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
  SampleRate.kHz_8: 8000,
  SampleRate.kHz_16: 16000,
  SampleRate.kHz_32: 32000,
  SampleRate.kHz_44_1: 44100,
  SampleRate.kHz_48: 48000,
};
