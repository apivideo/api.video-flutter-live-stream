import 'package:json_annotation/json_annotation.dart';

import 'channel.dart';
import 'sample_rate.dart';

part 'audio_parameters.g.dart';

@JsonSerializable()
class AudioParameters {
  int bitrate;
  Channel channel;
  SampleRate sampleRate;
  bool enableEchoCanceler;
  bool enableNoiseSuppressor;

  AudioParameters(
      {required this.bitrate,
      required this.channel,
      required this.sampleRate,
      this.enableEchoCanceler = true,
      this.enableNoiseSuppressor = true});

  factory AudioParameters.fromJson(Map<String, dynamic> json) =>
      _$AudioParametersFromJson(json);

  Map<String, dynamic> toJson() => _$AudioParametersToJson(this);
}
