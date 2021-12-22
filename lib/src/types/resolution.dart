import 'package:json_annotation/json_annotation.dart';

enum Resolution {
  @JsonValue("240p")
  RESOLUTION_240,
  @JsonValue("360p")
  RESOLUTION_360,
  @JsonValue("480p")
  RESOLUTION_480,
  @JsonValue("720p")
  RESOLUTION_720,
  @JsonValue("1080")
  RESOLUTION_1080,
  @JsonValue("2160p")
  RESOLUTION_2160,
}
