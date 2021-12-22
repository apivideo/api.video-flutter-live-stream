import 'package:apivideo_live_stream/apivideo_live_stream.dart';

List<String> resolutionsToPrettyString() {
  List<String> list = [];
  for (final res in Resolution.values) {
    var str = res.toPrettyString();
    list.add(str);
  }

  return list;
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
      case Resolution.RESOLUTION_2160:
        result = "3860x2160";
        break;
      default:
        result = "1280x720";
        break;
    }
    return result;
  }
}
