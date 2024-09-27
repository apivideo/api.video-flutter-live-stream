import 'dart:ui';

class ApiVideoLiveStreamEventsListener {
  /// Gets notified when the connection is successful
  final VoidCallback? onConnectionSuccess;

  /// Gets notified when the connection failed
  final Function(String)? onConnectionFailed;

  /// Gets notified when the device has been disconnected
  final VoidCallback? onDisconnection;

  /// Gets notified when the video size has changed. Mostly designed to update Widget aspect ratio.
  final Function(Size)? onVideoSizeChanged;

  /// Gets notified when an error occurs
  final Function(Exception)? onError;

  ApiVideoLiveStreamEventsListener(
      {this.onConnectionSuccess,
      this.onConnectionFailed,
      this.onDisconnection,
      this.onVideoSizeChanged,
      this.onError});
}

class ApiVideoLiveStreamWidgetListener {
  final VoidCallback? onTextureReady;

  ApiVideoLiveStreamWidgetListener({this.onTextureReady});
}
