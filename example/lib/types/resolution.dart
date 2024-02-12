import 'package:apivideo_live_stream/apivideo_live_stream.dart';

Map<Resolution, String> getResolutionsMap() {
  Map<Resolution, String> map = {};
  for (final res in Resolution.values) {
    map[res] = res.toPrettyString();
  }
  return map;
}

extension ResolutionExtension on Resolution {
  String toPrettyString() {
    return "${this.size.width.toInt()}x${this.size.height.toInt()}";
  }
}
