import 'package:json_annotation/json_annotation.dart';

/// Enumeration for supported RTMP sample rate
enum SampleRate {
  /// 11025 Hz
  @JsonValue(11025)
  kHz_11,

  /// 22050 Hz
  @JsonValue(22050)
  kHz_22,

  /// 44100 Hz
  @JsonValue(44100)
  kHz_44_1,
}
