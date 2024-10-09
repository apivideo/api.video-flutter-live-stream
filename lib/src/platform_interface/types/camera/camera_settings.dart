import 'package:meta/meta.dart';

abstract class ZoomRatio {
  /// Gets the current zoom ratio.
  Future<double> get zoomRatio async {
    throw UnimplementedError('getZoomRatio() has not been implemented.');
  }

  /// Sets the zoom ratio.
  /// The value must be between [zoomRatioRange].
  /// 1.0 means no zoom.
  Future<void> setZoomRatio(double zoomRatio) {
    throw UnimplementedError('setZoomRatio() has not been implemented.');
  }
}

abstract class CameraSettings {
  /// Gets the current zoom settings.
  final ZoomRatio zoom;

  @internal
  const CameraSettings(this.zoom);
}
