import 'package:json_annotation/json_annotation.dart';

/// Enumeration for supported RTMP sample rate
@JsonEnum(valueField: 'value')
enum SampleRate {
  /// 11025 Hz
  kHz_11(value: 11025),

  /// 22050 Hz
  kHz_22(value: 22050),

  /// 44100 Hz
  kHz_44_1(value: 44100);

  const SampleRate({required this.value});

  final int value;
}
