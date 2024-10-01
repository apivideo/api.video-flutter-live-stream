import 'dart:ui';

mixin ApiVideoLiveStreamEventsListener {
  /// Gets notified when the connection is successful
  void onConnectionSuccess() {}

  /// Gets notified when the connection failed
  void onConnectionFailed(String reason) {}

  /// Gets notified when the device has been disconnected
  void onDisconnection() {}

  /// Gets notified when the video size has changed. Mostly designed to update Widget aspect ratio.
  void onVideoSizeChanged(Size size) {}

  /// Gets notified when an error occurs
  void onError(Exception error) {}
}

mixin ApiVideoLiveStreamWidgetListener {
  void onTextureReady() {}
}
