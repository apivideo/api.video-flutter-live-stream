import 'package:apivideo_live_stream_example/utils/set.dart';

Set<int> sampleRates = {22050, 44100};

Map<int, String> inflateSampleRatesMap() {
  return sampleRates.toDisplayMap(
      valueTransformation: sampleRateToPrettyString);
}

String sampleRateToPrettyString(int sampleRate) {
  return "${sampleRate / 1000} KHz";
}
