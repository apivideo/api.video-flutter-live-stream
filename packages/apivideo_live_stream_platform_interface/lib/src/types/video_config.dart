import 'dart:ui';

import 'package:apivideo_live_stream_platform_interface/src/utils/SizeJsonConverter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'video_config.g.dart';

/// Live streaming video configuration.
@JsonSerializable()
class VideoConfig {
  /// The video bitrate in bps
  final int bitrate;

  /// The live streaming video resolution
  @SizeConverter()
  final Size resolution;

  /// The video frame rate in fps
  final int fps;

  /// The GOP (Group of Pictures) duration
  final Duration gopDuration;

  /// Creates a [VideoConfig] instance
  const VideoConfig.withBitrate(
      {required this.bitrate,
      this.resolution = defaultResolution,
      this.fps = 30,
      this.gopDuration = defaultGopDuration})
      : assert(bitrate > 0),
        assert(fps > 0);

  /// Creates a [VideoConfig] instance where bitrate is set according to the given [resolution].
  VideoConfig(
      {this.resolution = defaultResolution,
      this.fps = 30,
      this.gopDuration = defaultGopDuration})
      : assert(fps > 0),
        bitrate = _getDefaultBitrate(resolution);

  /// Creates a [VideoConfig] from a [json] map.
  factory VideoConfig.fromJson(Map<String, dynamic> json) =>
      _$VideoConfigFromJson(json);

  /// Creates a json map from a [VideoConfig].
  Map<String, dynamic> toJson() => _$VideoConfigToJson(this);

  /// Returns the default bitrate for the given [resolution].
  static int _getDefaultBitrate(Size size) {
    final pixelCount = size.width * size.height;

    if (pixelCount <= 102240) {
      return 800000; // for 4/3 and 16/9 240p
    } else if (pixelCount <= 230400) {
      return 1000000; // for 16/9 360p
    } else if (pixelCount <= 409920) {
      return 1300000; // for 4/3 and 16/9 480p
    } else if (pixelCount <= 921600) {
      return 2000000; // for 4/3 600p, 4/3 768p and 16/9 720p
    } else {
      return 3000000; // for 16/9 1080p
    }
  }

  static const Duration defaultGopDuration = const Duration(seconds: 2);
  static const Size defaultResolution = const Size(1280, 720);
}
