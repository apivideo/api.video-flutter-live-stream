import 'package:apivideo_live_stream/apivideo_live_stream.dart';

List<String> channelsToPrettyString() {
  List<String> list = [];
  for (final res in Channel.values) {
    var str = res.toPrettyString();
    list.add(str);
  }

  return list;
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
