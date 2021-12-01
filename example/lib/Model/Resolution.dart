enum Resolution{
  RESOLUTION_240,
  RESOLUTION_360,
  RESOLUTION_480,
  RESOLUTION_720,
  RESOLUTION_1080,
  RESOLUTION_2160,
}

extension ResolutionExtension on Resolution{
  List<String> getAllResolutionsToString(){
    List<String> list = [];
    for(final res in Resolution.values){
      var str = getResolutionToString(res);
      list.add(str);
    }

    return list;
  }

  String getResolutionToString(Resolution res){
    var result = "";
    switch(res){
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
  String getSimpleResolutionToString(Resolution res){
    var result = "";
    switch(res){
      case Resolution.RESOLUTION_240:
        result = "240p";
        break;
      case Resolution.RESOLUTION_360:
        result = "360p";
        break;
      case Resolution.RESOLUTION_480:
        result = "480p";
        break;
      case Resolution.RESOLUTION_720:
        result = "720p";
        break;
      case Resolution.RESOLUTION_1080:
        result = "1080p";
        break;
      case Resolution.RESOLUTION_2160:
        result = "2160p";
        break;
      default:
        result = "720p";
        break;
    }
    return result;
  }
}