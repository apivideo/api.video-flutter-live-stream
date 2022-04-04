import 'package:json_annotation/json_annotation.dart';

enum SampleRate {
  @JsonValue(11025)
  kHz_11,
  @JsonValue(22050)
  kHz_22,
  @JsonValue(44100)
  kHz_44_1,
}
