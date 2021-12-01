enum AudioBitrate {
  Kbps_24,
  Kbps_64,
  Kbps_128,
  Kbps_192,
}

extension AudioBitrateExtension on AudioBitrate {
  List<String> getAllAudioBitratesToString() {
    List<String> list = [];
    for (final res in AudioBitrate.values) {
      var str = getAudioBitrateToString(res);
      list.add(str);
    }

    return list;
  }

  String getAudioBitrateToString(AudioBitrate audio) {
    var result = "";
    switch (audio) {
      case AudioBitrate.Kbps_24:
        result = "24 Kbps";
        break;
      case AudioBitrate.Kbps_64:
        result = "64 Kbps";
        break;
      case AudioBitrate.Kbps_128:
        result = "128 Kbps";
        break;
      case AudioBitrate.Kbps_192:
        result = "192 Kbps";
        break;
      default:
        result = "128 Kbps";
        break;
    }
    return result;
  }

}
