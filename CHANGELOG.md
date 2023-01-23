# Changelog

All changes to this project will be documented in this file.

## [1.1.1] - 2023-01-23

- iOS: fix the orientation when device is turned

## [1.1.0] - 2023-01-11

- Major refactor:
    - use `initialize` instead of `create` and pass default parameters
      to `ApiVideoLiveStreamController` constructor
    - simplified usage of `CameraPreview` (and renamed to `ApiVideoCameraPreview`)
- Getter for properties such as `isMuted`, `cameraPosition`, ... (
  see [#13](https://github.com/apivideo/api.video-flutter-live-stream/issues/13))
- Few fixes on Android and iOS

## [1.0.7] - 2022-10-12

- Fix crash on `stopStreaming`.
  See [#14](https://github.com/apivideo/api.video-flutter-live-stream/issues/14)

## [1.0.6] - 2022-09-30

- Fix 1080p configuration.
  See [#16](https://github.com/apivideo/api.video-flutter-live-stream/issues/16)
- Upgrade HaishinKit to 1.3.0.
  See [#15](https://github.com/apivideo/api.video-flutter-live-stream/issues/15)
- Upgrade dependencies

## [1.0.5] - 2022-08-03

- Few fixes on FLV/RTMP to increase compatibility
- iOS: fix landscape orientation.
  See [#12](https://github.com/apivideo/api.video-flutter-live-stream/issues/12)

## [1.0.4] - 2022-06-01

- iOS: Fix the random aspect ratio of the preview and random crashes.
  See [#7](https://github.com/apivideo/api.video-flutter-live-stream/issues/7)

## [1.0.3] - 2022-05-30

- Android: do not obfuscate rtmpdroid classes to
  fix [#6](https://github.com/apivideo/api.video-flutter-live-stream/issues/6)

## [1.0.2] - 2022-05-25

- iOS: implements `stopPreview` and `startPreview` to
  fix [#4](https://github.com/apivideo/api.video-flutter-live-stream/issues/4)

## [1.0.1] - 2022-04-13

- Fix audio and video configuration for iOS
- Fix setAudioConfig when preview is running for Android

## [1.0.0] - 2022-04-08

- Initial release.
