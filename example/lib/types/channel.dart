import 'package:apivideo_live_stream/apivideo_live_stream.dart';

Map<Channel, String> getChannelsMap() {
  Map<Channel, String> map = {};
  for (final res in Channel.values) {
    map[res] = res.toPrettyString();
  }
  return map;
}

extension ChannelExtension on Channel {
  String toPrettyString() {
    var result = "";
    switch (this) {
      case Channel.mono:
        result = "mono";
        break;
      case Channel.stereo:
        result = "stereo";
        break;
      default:
        result = "stereo";
        break;
    }
    return result;
  }
}
