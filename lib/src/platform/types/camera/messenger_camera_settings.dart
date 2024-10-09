import 'package:apivideo_live_stream/apivideo_live_stream.dart';
import 'package:apivideo_live_stream/src/platform/generated/live_stream_api.g.dart';
import 'package:flutter/services.dart';

/// An implementation of [ZoomRatio] using the messenger API.
class MessengerZoomRatio extends ZoomRatio {
  MessengerZoomRatio(this._api);

  final CameraSettingsHostApi _api;

  @override
  Future<double> get zoomRatio async {
    return _api.getZoomRatio();
  }

  @override
  Future<void> setZoomRatio(double zoomRatio) {
    return _api.setZoomRatio(zoomRatio);
  }
}

class MessengerCameraSettings extends CameraSettings {
  MessengerCameraSettings(CameraSettingsHostApi api)
      : super(MessengerZoomRatio(api));

  MessengerCameraSettings.detached({BinaryMessenger? binaryMessenger})
      : this(CameraSettingsHostApi(binaryMessenger: binaryMessenger));
}
