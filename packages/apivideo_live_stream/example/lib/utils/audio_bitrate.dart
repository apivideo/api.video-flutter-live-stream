import 'package:apivideo_live_stream_example/utils/set.dart';

Set<int> audioBitrateList = {32000, 64000, 128000, 192000};

Map<int, String> inflateAudioBitrateMap() {
  return audioBitrateList.toDisplayMap(
      valueTransformation: bitrateToPrettyString);
}

String bitrateToPrettyString(int bitrate) {
  return "${bitrate / 1000} Kbps";
}
