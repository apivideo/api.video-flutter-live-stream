import 'package:json_annotation/json_annotation.dart';

enum SampleRate {
  @JsonValue(8000)
  kHz_8,
  @JsonValue(16000)
  kHz_16,
  @JsonValue(32000)
  kHz_32,
  @JsonValue(44100)
  kHz_44_1,
  @JsonValue(48000)
  kHz_48,
}
