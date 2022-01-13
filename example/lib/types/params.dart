import 'package:apivideo_live_stream/apivideo_live_stream.dart';
import 'package:apivideo_live_stream_example/types/sample_rate.dart';

import 'channel.dart';
import 'resolution.dart';

class Params {
  final VideoParameters video = VideoParameters(
    bitrate: 2 * 1024 * 1024,
    resolution: Resolution.RESOLUTION_720,
    fps: 30,
  );
  final AudioParameters audio = AudioParameters(
      bitrate: 128 * 1000,
      channel: Channel.stereo,
      sampleRate: SampleRate.kHz_48);
  String? rtmpUrl;
  String streamKey = "";

  String getResolutionToString() {
    return video.resolution.toPrettyString();
  }

  String getChannelToString() {
    return audio.channel.toPrettyString();
  }

  static String bitrateToPrettyString(int bitrate) {
    return "${bitrate / 1000} Kbps";
  }

  String getBitrateToString() {
    return bitrateToPrettyString(audio.bitrate);
  }

  String getSampleRateToString() {
    return audio.sampleRate.toPrettyString();
  }
}
