import 'package:apivideo_live_stream_example/Model/AudioBitrate.dart';
import 'package:apivideo_live_stream_example/Model/AudioSampleRate.dart';
import 'package:apivideo_live_stream_example/Model/Resolution.dart';
import 'Channel.dart';

class Params {
  Resolution resolution;
  int fps;
  int bitrate;
  Channel channel;
  AudioBitrate audioBitrate;
  AudioSampleRate audioSampleRate;
  bool isEchocanceled;
  bool isNoiseSuppressed;
  String rtmpUrl;
  late String streamKey;

  Params(
      {this.resolution = Resolution.RESOLUTION_720,
      this.fps = 24,
      this.bitrate = 1280000,
      this.channel = Channel.stereo,
      this.audioBitrate = AudioBitrate.Kbps_128,
      this.audioSampleRate = AudioSampleRate.kHz_44_1,
      this.isEchocanceled = false,
      this.isNoiseSuppressed = false,
      this.rtmpUrl = "rtmp://broadcast.api.video/s",
      required this.streamKey});

  String getResolutionToString() {
    Resolution resolution = this.resolution;
    return resolution.getResolutionToString(this.resolution);
  }

  String getSimpleResolutionToString() {
    Resolution resolution = this.resolution;
    return resolution.getResolutionToString(this.resolution);
  }

  String getChannelToString() {
    Channel channel = this.channel;
    return channel.getChannelToString(this.channel);
  }

  String getAudioBitrateToString() {
    AudioBitrate audio = this.audioBitrate;
    return audio.getAudioBitrateToString(this.audioBitrate);
  }

  String getAudioSampleRateToString() {
    AudioSampleRate audio = this.audioSampleRate;
    return audio.getAudioSampleRateToString(this.audioSampleRate);
  }
}
