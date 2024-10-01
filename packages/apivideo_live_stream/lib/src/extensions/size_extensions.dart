import 'dart:ui';

import 'package:apivideo_live_stream/src/platform/generated/live_stream_api.g.dart';
import 'package:meta/meta.dart';

@internal
extension NativeResolutionConvertion on Size {
  @internal
  NativeResolution toNative() {
    return NativeResolution(width: width.toInt(), height: height.toInt());
  }
}

@internal
extension SizeConvertion on NativeResolution {
  @internal
  Size toSize() {
    return Size(width.toDouble(), height.toDouble());
  }
}
