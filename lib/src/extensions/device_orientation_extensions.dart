import 'package:flutter/services.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

extension NativeDeviceOrientationInDegress on NativeDeviceOrientation {
  int toDegress() {
    return deviceOrientation!.toDegress();
  }
}

extension DeviceOrientationInDegress on DeviceOrientation {
  int toDegress() {
    final Map<DeviceOrientation, int> degreesForDeviceOrientation =
        <DeviceOrientation, int>{
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeRight: 90,
      DeviceOrientation.portraitDown: 180,
      DeviceOrientation.landscapeLeft: 270,
    };
    return degreesForDeviceOrientation[this]!;
  }
}
