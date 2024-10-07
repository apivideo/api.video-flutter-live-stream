import 'package:flutter/services.dart';

import 'platform/generated/live_stream_api.g.dart';

class DeviceOrientationManager {
  /// Retrieves the current UI orientation based on the current device
  /// orientation and screen rotation.
  static Future<DeviceOrientation> getUiOrientation(
      {BinaryMessenger? binaryMessenger}) async {
    final DeviceOrientationManagerHostApi api =
        DeviceOrientationManagerHostApi(binaryMessenger: binaryMessenger);

    final String orientation = await api.getUiOrientation();
    return orientation._deserializeDeviceOrientation();
  }
}

extension DeviceOrientationSerialization on DeviceOrientation {
  String _serializeDeviceOrientation() {
    switch (this) {
      case DeviceOrientation.portraitUp:
        return 'portraitUp';
      case DeviceOrientation.landscapeRight:
        return 'landscapeRight';
      case DeviceOrientation.portraitDown:
        return 'portraitDown';
      case DeviceOrientation.landscapeLeft:
        return 'landscapeLeft';
    }
  }
}

extension StringDeviceOrientationDeserialization on String {
  DeviceOrientation _deserializeDeviceOrientation() {
    switch (this) {
      case 'portraitUp':
        return DeviceOrientation.portraitUp;
      case 'landscapeRight':
        return DeviceOrientation.landscapeRight;
      case 'portraitDown':
        return DeviceOrientation.portraitDown;
      case 'landscapeLeft':
        return DeviceOrientation.landscapeLeft;
      default:
        throw ArgumentError.value(this, 'value', 'Invalid device orientation');
    }
  }
}
