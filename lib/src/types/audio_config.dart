import 'package:apivideo_live_stream/src/platform/generated/live_stream_api.g.dart';
import 'package:meta/meta.dart';

/// Live streaming audio configuration.
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

  /// Returns a [NativeAudioConfig] instance.
  @internal
  NativeAudioConfig toNative() {
    return NativeAudioConfig(
        bitrate: bitrate,
        channel: channel,
        sampleRate: sampleRate,
        enableEchoCanceler: enableEchoCanceler,
        enableNoiseSuppressor: enableNoiseSuppressor);
  }

  /// Returns a [AudioConfig] instance from a [NativeAudioConfig] instance.
  @internal
  static AudioConfig fromNative(NativeAudioConfig nativeAudioConfig) {
    return AudioConfig(
      bitrate: nativeAudioConfig.bitrate,
      channel: nativeAudioConfig.channel,
      sampleRate: nativeAudioConfig.sampleRate,
      enableEchoCanceler: nativeAudioConfig.enableEchoCanceler,
      enableNoiseSuppressor: nativeAudioConfig.enableNoiseSuppressor,
    );
  }
}
