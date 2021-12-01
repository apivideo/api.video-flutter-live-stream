enum AudioSampleRate{
  kHz_8,
  kHz_16,
  kHz_32,
  kHz_44_1,
  kHz_48,
}

extension AudioSampleRateExtension on AudioSampleRate{
  List<String> getAllAudioSampleRatesToString(){
    List<String> list = [];
    for(final res in AudioSampleRate.values){
      var str = getAudioSampleRateToString(res);
      list.add(str);
    }

    return list;
  }

  String getAudioSampleRateToString(AudioSampleRate sample){
    var result = "";
    switch(sample){
      case AudioSampleRate.kHz_8:
        result = "8 kHz";
        break;
      case AudioSampleRate.kHz_16:
        result = "16 kHz";
        break;
      case AudioSampleRate.kHz_32:
        result = "32 kHz";
        break;
      case AudioSampleRate.kHz_44_1:
        result = "44.1 kHz";
        break;
      case AudioSampleRate.kHz_48:
        result = "48 kHz";
        break;
      default:
        result = "32 kHz";
        break;
    }
    return result;
  }
}