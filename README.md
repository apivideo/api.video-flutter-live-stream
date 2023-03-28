[![badge](https://img.shields.io/twitter/follow/api_video?style=social)](https://twitter.com/intent/follow?screen_name=api_video)
&nbsp; [![badge](https://img.shields.io/github/stars/apivideo/api.video-flutter-live-stream?style=social)](https://github.com/apivideo/api.video-flutter-live-stream)
&nbsp; [![badge](https://img.shields.io/discourse/topics?server=https%3A%2F%2Fcommunity.api.video)](https://community.api.video)
![](https://github.com/apivideo/.github/blob/main/assets/apivideo_banner.png)

<h1 align="center">Flutter RTMP live stream client</h1>

[api.video](https://api.video) is the video infrastructure for product builders. Lightning fast
video APIs for integrating, scaling, and managing on-demand & low latency live streaming features in
your app.

# Table of contents

- [Table of contents](#table-of-contents)
- [Project description](#project-description)
- [Getting started](#getting-started)
    - [Installation](#installation)
    - [Permissions](#permissions)
    - [Code sample](#code-sample)
- [Example App](#example-app)
    - [Setup](#setup)
        - [Android](#android)
        - [iOS](#ios)
- [Plugins](#plugins)
- [FAQ](#faq)

# Project description

This module is made for broadcasting RTMP live stream from smartphone camera.

# Getting started

## Installation

In your pubspec.yaml file, add the following:

```yaml
dependencies:
  apivideo_live_stream: ^1.1.1
```

In your dart file, import the package:

```dart 
import 'package:apivideo_live_stream/apivideo_live_stream.dart';
```

## Permissions

To be able to broadcast, you must:

1) On Android: ask for internet, camera and microphone permissions:

```xml

<manifest>
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.CAMERA" />
</manifest>
```

The library will require android.permission.CAMERA and android.permission.RECORD_AUDIO at runtime.

2) On iOS: update the Info.plist with a usage description for camera and microphone

```xml

<key>NSCameraUsageDescription</key><string>Your own description of the purpose</string>

<key>NSMicrophoneUsageDescription</key><string>Your own description of the purpose</string>
```

## Code sample

1. Creates a live stream controller

```dart

final ApiVideoLiveStreamController _controller = ApiVideoLiveStreamController(
    initialAudioConfig: AudioConfig(), initialVideoConfig: VideoConfig.withDefaultBitrate());
```

2. Initializes the live stream controller

```dart
await _controller.initialize();
```

3. Adds a CameraPreview widget as a child of your view

Ensure that _controller.create() has been finished before creating the CameraPreview widget.

```dart
child: ApiVideoCameraPreview(controller: _controller),
```

4. Starts a live stream

```dart
_controller.startStreaming("YOUR_STREAM_KEY");
```

5. Stops streaming and preview

```dart
_controller.stop();
```

### Manages application lifecycle

On the application side, you must manage application lifecycle:

```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.inactive) {
    _controller.stop();
  } else if (state == AppLifecycleState.resumed) {
    _controller.startPreview();
  }
}
```

# Example App

You can try
our [example app](https://github.com/apivideo/api.video-flutter-live-stream/tree/master/example),
feel free to test it.

## Setup

Be sure to follow the [Flutter installation steps](https://docs.flutter.dev/get-started/) before
anything.

1) Open Android Studio
2) File > New > Project from Version Control

In URL field, type:

```shell
git@github.com:apivideo/api.video-flutter-live-stream.git
```

Wait for the indexation to finish.

### Android

Connect an Android device to your computer and click on the `Run main.dart` button.

### iOS

1) Connect an iOS device to your computer and click on the `Run main.dart` button.

2) The build will fail because you haven't set your development profile, sign your application:

Open Xcode, click on "Open a project or file" and open
the `YOUR_PROJECT_NAME/example/ios/Runner.xcworkspace` file.
<br />Click on Example, go in `Signin & Capabilities` tab, add your team and create a unique bundle
identifier.

# Plugins

api.video Flutter live stream library is using external native library:

| Plugin     | README       |
|------------|--------------|
| StreamPack | [StreamPack] |
| HaishinKit | [HaishinKit] |

# FAQ

If you have any questions, ask us in the [community](https://community.api.video). Or
use [issues](https://github.com/apivideo/api.video-flutter-live-stream/issues).

[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)

[StreamPack]: <https://github.com/ThibaultBee/StreamPack>

[HaishinKit]: <https://github.com/shogo4405/HaishinKit.swift>

