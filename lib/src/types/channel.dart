import 'package:json_annotation/json_annotation.dart';

enum Channel {
  @JsonValue("stereo")
  stereo,
  @JsonValue("mono")
  mono,
}
