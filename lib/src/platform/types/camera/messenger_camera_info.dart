import 'package:apivideo_live_stream/apivideo_live_stream.dart';
import 'package:apivideo_live_stream/src/platform/extensions/lens_direction_extensions.dart';
import 'package:apivideo_live_stream/src/platform/generated/live_stream_api.g.dart';
import 'package:flutter/services.dart';

/// A builder for creating [CameraInfo] instances using the messenger API.
class MessengerCameraInfoBuilder {
  MessengerCameraInfoBuilder(this.cameraId, {BinaryMessenger? binaryMessenger})
      : _api = CameraInfoHostApi(binaryMessenger: binaryMessenger);

  final CameraInfoHostApi _api;
  final String cameraId;

  Future<ZoomState> _createZoomState() async {
    final minZoomRatio = await _api.getMinZoomRatio(cameraId);
    final maxZoomRatio = await _api.getMaxZoomRatio(cameraId);

    return ZoomState(minZoomRatio, maxZoomRatio);
  }

  Future<CameraInfo> create() async {
    final zoomState = await _createZoomState();
    final lensDirection = await _api.getLensDirection(cameraId);
    final sensorOrientationDegrees =
        await _api.getSensorRotationDegrees(cameraId);
    return CameraInfo(cameraId, lensDirection.toLensDirection(),
        sensorOrientationDegrees, zoomState);
  }
}
