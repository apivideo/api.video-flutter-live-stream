import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

import 'controller.dart';
import 'listeners.dart';

/// Widget that displays the camera preview of [controller].
///
class ApiVideoCameraPreview extends StatefulWidget {
  /// Creates a new [ApiVideoCameraPreview] instance for [controller] and a [child] overlay.
  const ApiVideoCameraPreview(
      {super.key,
      required this.controller,
      this.enableZoomOnPinch = false,
      this.fit = BoxFit.contain,
      this.child});

  /// The controller for the camera to display the preview for.
  final ApiVideoLiveStreamController controller;

  /// Enables zooming on pinch.
  final bool enableZoomOnPinch;

  /// The [BoxFit] for the video. The [child] is scale to the preview box.
  final BoxFit fit;

  /// A widget to overlay on top of the camera preview. It is scaled to the camera preview [FittedBox].
  final Widget? child;

  @override
  State<ApiVideoCameraPreview> createState() => _ApiVideoCameraPreviewState();
}

class _ApiVideoCameraPreviewState extends State<ApiVideoCameraPreview>
    with ApiVideoLiveStreamEventsListener, ApiVideoLiveStreamWidgetListener {
  late int _textureId;

  double _aspectRatio = 1.77;
  Size _size = const Size(1280, 720);

  @override
  void initState() {
    super.initState();
    _textureId = widget.controller.textureId;
    widget.controller.addWidgetListener(this);
    widget.controller.addEventsListener(this);
    if (widget.controller.isInitialized) {
      widget.controller.videoSize.then((size) {
        if (size != null) {
          _updateAspectRatio(size);
        }
      });
    }
  }

  @override
  void dispose() {
    widget.controller.stopPreview();
    widget.controller.removeWidgetListener(this);
    widget.controller.removeEventsListener(this);
    super.dispose();
  }

  void onTextureReady() {
    final int newTextureId = widget.controller.textureId;
    if (newTextureId != _textureId) {
      setState(() {
        _textureId = newTextureId;
      });
    }
  }

  void onVideoSizeChanged(Size size) {
    _updateAspectRatio(size);
  }

  @override
  Widget build(BuildContext context) {
    return _textureId == ApiVideoLiveStreamController.kUninitializedTextureId
        ? Container()
        : _buildPreview(context);
  }

  Widget _buildPreview(BuildContext context) {
    return NativeDeviceOrientationReader(builder: (context) {
      final orientation = NativeDeviceOrientationReader.orientation(context);
      return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(alignment: Alignment.center, children: [
          _buildFittedPreview(constraints, orientation),
          _buildFittedOverlay(constraints, orientation)
        ]);
      });
    });
  }

  Widget _buildFittedPreview(
      BoxConstraints constraints, NativeDeviceOrientation orientation) {
    final orientedSize = _size.orientate(orientation);
    // See https://github.com/flutter/flutter/issues/17287
    return GestureDetector(
        onScaleUpdate: (details) {
          if (widget.enableZoomOnPinch) _onScaleUpdate(details);
        },
        child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: FittedBox(
                fit: widget.fit,
                clipBehavior: Clip.hardEdge,
                child: Center(
                    child: SizedBox(
                        width: orientedSize.width,
                        height: orientedSize.height,
                        child: _wrapInRotatedBox(
                            orientation: orientation,
                            child: widget.controller.buildPreview()))))));
  }

  Widget _buildFittedOverlay(
      BoxConstraints constraints, NativeDeviceOrientation orientation) {
    final orientedSize = _size.orientate(orientation);
    final fittedSize =
        applyBoxFit(widget.fit, orientedSize, constraints.biggest);
    return SizedBox(
        width: fittedSize.destination.width,
        height: fittedSize.destination.height,
        child: widget.child ?? Container());
  }

  void _onScaleUpdate(ScaleUpdateDetails details) async {
    final cameraSettings = await widget.controller.cameraSettings;

    final zoomRatio = await cameraSettings.zoom.zoomRatio;
    final double newZoomRatio = zoomRatio + (details.scale - 1) * 0.5;
    cameraSettings.zoom.setZoomRatio(newZoomRatio);
  }

  Widget _wrapInRotatedBox(
      {required NativeDeviceOrientation orientation, required Widget child}) {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return child;
    }

    return RotatedBox(
      quarterTurns: orientation.getQuarterTurns(),
      child: child,
    );
  }

  void _updateAspectRatio(Size newSize) async {
    final double newAspectRatio = newSize.aspectRatio;
    if ((newAspectRatio != _aspectRatio) || (newSize != _size)) {
      if (mounted) {
        setState(() {
          _size = newSize;
          _aspectRatio = newAspectRatio;
        });
      }
    }
  }
}

extension OrientationHelper on NativeDeviceOrientation {
  /// Returns true if the orientation is portrait.
  bool isLandscape() {
    return [
      NativeDeviceOrientation.landscapeLeft,
      NativeDeviceOrientation.landscapeRight
    ].contains(this);
  }

  /// Returns the number of clockwise quarter turns the orientation is rotated
  int getQuarterTurns() {
    Map<NativeDeviceOrientation, int> turns = {
      NativeDeviceOrientation.unknown: 0,
      NativeDeviceOrientation.portraitUp: 0,
      NativeDeviceOrientation.landscapeRight: 1,
      NativeDeviceOrientation.portraitDown: 2,
      NativeDeviceOrientation.landscapeLeft: 3,
    };
    return turns[this]!;
  }
}

extension OrientedSize on Size {
  /// Returns the size with width and height swapped if [orientation] is portrait.
  Size orientate(NativeDeviceOrientation orientation) {
    if (orientation.isLandscape()) {
      return Size(width, height);
    } else {
      return Size(height, width);
    }
  }
}
