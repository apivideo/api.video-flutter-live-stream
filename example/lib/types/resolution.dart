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
    var result = "";
    switch (this) {
      case Resolution.RESOLUTION_240:
        result = "352x240";
        break;
      case Resolution.RESOLUTION_360:
        result = "640x360";
        break;
      case Resolution.RESOLUTION_480:
        result = "858x480";
        break;
      case Resolution.RESOLUTION_720:
        result = "1280x720";
        break;
      case Resolution.RESOLUTION_1080:
        result = "1920x1080";
        break;
      default:
        result = "1280x720";
        break;
    }
    return result;
  }
}
