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
    return "${this.value / 1000} KHz";
  }
}
