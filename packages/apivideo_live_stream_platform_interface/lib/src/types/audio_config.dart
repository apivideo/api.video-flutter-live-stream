import 'package:json_annotation/json_annotation.dart';

part 'audio_config.g.dart';

/// Audio channel
enum Channel {
  /// Stereo (2 channels)
  @JsonValue("stereo")
  stereo,

  /// Mono (1 channel)
  @JsonValue("mono")
  mono,
}

/// Live streaming audio configuration.
@JsonSerializable()
class AudioConfig {
  /// The video bitrate in bps
  final int bitrate;

  /// The number of audio channels
  /// Only available on Android
  final Channel channel;

  /// The sample rate of the audio capture
  /// Only available on Android
  /// Example: 44100, 48000, 96000
  /// For RTMP sample rate, only 11025, 22050, 44100 are supported
  final int sampleRate;

  /// Enable the echo cancellation
  /// Only available on Android
  final bool enableEchoCanceler;

  /// Enable the noise suppressor
  /// Only available on Android
  final bool enableNoiseSuppressor;

  /// Creates a new [AudioConfig] instance.
  ///
  /// [sampleRate] is only supported on Android.
  /// [channel] is only supported on Android.
  const AudioConfig(
      {this.bitrate = 128000,
      this.channel = Channel.stereo,
      this.sampleRate = 44100,
      this.enableEchoCanceler = true,
      this.enableNoiseSuppressor = true})
      : assert(bitrate > 0);

  /// Creates a [AudioConfig] from a [json] map.
  factory AudioConfig.fromJson(Map<String, dynamic> json) =>
      _$AudioConfigFromJson(json);

  /// Creates a json map from a [AudioConfig].
  Map<String, dynamic> toJson() => _$AudioConfigToJson(this);
}
