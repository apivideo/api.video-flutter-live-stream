import 'package:json_annotation/json_annotation.dart';

import 'channel.dart';
import 'sample_rate.dart';

part 'audio_parameters.g.dart';

/// Live streaming audio parameters
@JsonSerializable()
class AudioParameters {
  /// The video bitrate in bps
  int bitrate;

  /// The number of audio channels
  /// Only available on Android
  Channel channel;

  /// The sample rate of the audio capture
  /// Only available on Android
  SampleRate sampleRate;

  /// Enable the echo cancellation
  /// Only available on Android
  bool enableEchoCanceler;

  /// Enable the noise suppressor
  /// Only available on Android
  bool enableNoiseSuppressor;

  /// Creates a new [AudioParameters] instance.
  ///
  /// [sampleRate] is only supported on Android.
  /// [channel] is only supported on Android.
  AudioParameters(
      {required this.bitrate,
      required this.channel,
      required this.sampleRate,
      this.enableEchoCanceler = true,
      this.enableNoiseSuppressor = true});

  /// Creates a [AudioParameters] from a [json] map.
  factory AudioParameters.fromJson(Map<String, dynamic> json) =>
      _$AudioParametersFromJson(json);

  /// Creates a json map from a [AudioParameters].
  Map<String, dynamic> toJson() => _$AudioParametersToJson(this);
}
