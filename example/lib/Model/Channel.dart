enum Channel {
  stereo,
  mono,
}

extension ChannelExtension on Channel {
  List<String> getAllChannelsToString() {
    List<String> list = [];
    for (final res in Channel.values) {
      var str = getChannelToString(res);
      list.add(str);
    }

    return list;
  }

  String getChannelToString(Channel channel) {
    var result = "";
    switch (channel) {
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
