import 'package:apivideo_live_stream/src/platform_interface/types/range.dart';
import 'package:meta/meta.dart';

/// Camera facing direction
enum CameraLensDirection {
  /// Front camera
  front,

  /// Back camera
  back,

  /// Other camera (external for example)
  other;
}

class ZoomState {
  final double minZoomRatio;
  final double maxZoomRatio;

  @internal
  const ZoomState(this.minZoomRatio, this.maxZoomRatio);

  /// Gets the zoom ratio range.
  /// If the device does not support zoom, it will return a range from 1.0 to 1.0.
  /// When switching to another camera, you should call this method again.
  Range<double> get zoomRatioRange =>
      Range(min: minZoomRatio, max: maxZoomRatio);

  @override
  String toString() {
    return 'ZoomState{from: $minZoomRatio, to: $maxZoomRatio}';
  }
}

class CameraInfo {
  final String id;
  final CameraLensDirection lensDirection;
  final int sensorOrientationDegrees;

  final ZoomState zoom;

  @internal
  const CameraInfo(
      this.id, this.lensDirection, this.sensorOrientationDegrees, this.zoom);

  @override
  String toString() {
    return 'CameraInfo{id: $id, lensDirection: $lensDirection, sensorOrientationDegrees: $sensorOrientationDegrees, zoom: $zoom}';
  }
}
