import 'package:apivideo_live_stream/apivideo_live_stream.dart';
import 'package:apivideo_live_stream_example/utils/set.dart';

Map<Channel, String> inflateChannelsMap() {
  return Channel.values
      .toSet()
      .toDisplayMap(valueTransformation: (e) => e.toPrettyString());
}

extension ChannelPrettifier on Channel {
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
