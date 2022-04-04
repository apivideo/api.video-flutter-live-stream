import 'package:apivideo_live_stream/apivideo_live_stream.dart';

Map<SampleRate, String> getSampleRatesMap() {
  Map<SampleRate, String> map = {};
  for (final res in SampleRate.values) {
    map[res] = res.toPrettyString();
  }
  return map;
}

extension SampleRateExtension on SampleRate {
  String toPrettyString() {
    var result = "";
    switch (this) {
      case SampleRate.kHz_11:
        result = "11 kHz";
        break;
      case SampleRate.kHz_22:
        result = "22 kHz";
        break;
      case SampleRate.kHz_44_1:
        result = "44.1 kHz";
        break;
    }
    return result;
  }
}
