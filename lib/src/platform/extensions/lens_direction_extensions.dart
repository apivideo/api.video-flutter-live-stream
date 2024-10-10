import 'package:apivideo_live_stream/apivideo_live_stream.dart';
import 'package:apivideo_live_stream/src/platform/generated/live_stream_api.g.dart';
import 'package:meta/meta.dart';

@internal
extension NativeLensDirectionConvertion on CameraLensDirection {
  @internal
  NativeCameraLensDirection toNative() {
    switch (this) {
      case CameraLensDirection.front:
        return NativeCameraLensDirection.front;
      case CameraLensDirection.back:
        return NativeCameraLensDirection.back;
      case CameraLensDirection.other:
        return NativeCameraLensDirection.other;
    }
  }
}

@internal
extension LensDirectionConvertion on NativeCameraLensDirection {
  @internal
  CameraLensDirection toLensDirection() {
    switch (this) {
      case NativeCameraLensDirection.front:
        return CameraLensDirection.front;
      case NativeCameraLensDirection.back:
        return CameraLensDirection.back;
      case NativeCameraLensDirection.other:
        return CameraLensDirection.other;
    }
  }
}
