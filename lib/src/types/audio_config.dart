import 'package:json_annotation/json_annotation.dart';

import 'channel.dart';
import 'sample_rate.dart';

part 'audio_config.g.dart';

/// Live streaming audio configuration.
@JsonSerializable()
class AudioConfig {
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

  /// Creates a new [AudioConfig] instance.
  ///
  /// [sampleRate] is only supported on Android.
  /// [channel] is only supported on Android.
  AudioConfig(
      {this.bitrate = 128000,
      this.channel = Channel.stereo,
      this.sampleRate = SampleRate.kHz_44_1,
      this.enableEchoCanceler = true,
      this.enableNoiseSuppressor = true});

  /// Creates a [AudioConfig] from a [json] map.
  factory AudioConfig.fromJson(Map<String, dynamic> json) =>
      _$AudioConfigFromJson(json);

  /// Creates a json map from a [AudioConfig].
  Map<String, dynamic> toJson() => _$AudioConfigToJson(this);
}
