import 'package:apivideo_live_stream/apivideo_live_stream.dart';
import 'package:apivideo_live_stream_example/settings_screen.dart';
import 'package:apivideo_live_stream_example/types/params.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants.dart';

MaterialColor apiVideoOrange = const MaterialColor(0xFFFA5B30, const {
  50: const Color(0xFFFBDDD4),
  100: const Color(0xFFFFD6CB),
  200: const Color(0xFFFFD1C5),
  300: const Color(0xFFFFB39E),
  400: const Color(0xFFFA5B30),
  500: const Color(0xFFF8572A),
  600: const Color(0xFFF64819),
  700: const Color(0xFFEE4316),
  800: const Color(0xFFEC3809),
  900: const Color(0xFFE53101)
});

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: LiveViewPage(),
      theme: ThemeData(
        primarySwatch: apiVideoOrange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class LiveViewPage extends StatefulWidget {
  const LiveViewPage({Key? key}) : super(key: key);

  @override
  _LiveViewPageState createState() => new _LiveViewPageState();
}

class _LiveViewPageState extends State<LiveViewPage>
    with WidgetsBindingObserver {
  final ButtonStyle buttonStyle =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
  Params config = Params();
  late final LiveStreamController _controller;
  late final Future<int> textureId;

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);

    _controller = initLiveStreamController();
    textureId = _controller.create(
        initialAudioConfig: config.audio, initialVideoConfig: config.video);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _controller.stop();
    } else if (state == AppLifecycleState.resumed) {
      _controller.startPreview();
    }
  }

  LiveStreamController initLiveStreamController() {
    return LiveStreamController(onConnectionSuccess: () {
      print('Connection succedded');
    }, onConnectionFailed: (error) {
      print('Connection failed: $error');
      _showDialog(context, 'Connection failed', '$error');
      if (mounted) {
        setState(() {});
      }
    }, onDisconnection: () {
      showInSnackBar('Disconnected');
      if (mounted) {
        setState(() {});
      }
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Live Stream Example'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (choice) => _onMenuSelected(choice, context),
            itemBuilder: (BuildContext context) {
              return Constants.choices.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Center(
                    child: buildPreview(controller: _controller),
                  ),
                ),
              ),
            ),
            _controlRowWidget()
          ],
        ),
      ),
    );
  }

  void _onMenuSelected(String choice, BuildContext context) {
    if (choice == Constants.Settings) {
      _awaitResultFromSettingsFinal(context);
    }
  }

  void _awaitResultFromSettingsFinal(BuildContext context) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SettingsScreen(params: config)));
    _controller.setVideoConfig(config.video);
    _controller.setAudioConfig(config.audio);
  }

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _controlRowWidget() {
    final LiveStreamController? liveStreamController = _controller;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.cameraswitch),
          color: apiVideoOrange,
          onPressed:
              liveStreamController != null ? onSwitchCameraButtonPressed : null,
        ),
        IconButton(
          icon: const Icon(Icons.mic_off),
          color: apiVideoOrange,
          onPressed: liveStreamController != null
              ? onToggleMicrophoneButtonPressed
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.fiber_manual_record),
          color: Colors.red,
          onPressed:
              liveStreamController != null && !liveStreamController.isStreaming
                  ? onStartStreamingButtonPressed
                  : null,
        ),
        IconButton(
          icon: const Icon(Icons.stop),
          color: Colors.red,
          onPressed:
              liveStreamController != null && liveStreamController.isStreaming
                  ? onStopStreamingButtonPressed
                  : null,
        ),
      ],
    );
  }

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> switchCamera() async {
    final LiveStreamController? liveStreamController = _controller;

    if (liveStreamController == null) {
      showInSnackBar('Error: create a camera controller first.');
      return;
    }

    try {
      liveStreamController.switchCamera();
    } catch (error) {
      if (error is PlatformException) {
        _showDialog(
            context, "Error", "Failed to switch camera: ${error.message}");
      } else {
        _showDialog(context, "Error", "Failed to switch camera: $error");
      }
    }
  }

  Future<void> toggleMicrophone() async {
    final LiveStreamController? liveStreamController = _controller;

    if (liveStreamController == null) {
      showInSnackBar('Error: create a camera controller first.');
      return;
    }

    try {
      liveStreamController.toggleMute();
    } catch (error) {
      if (error is PlatformException) {
        _showDialog(
            context, "Error", "Failed to toggle mute: ${error.message}");
      } else {
        _showDialog(context, "Error", "Failed to toggle mute: $error");
      }
    }
  }

  Future<void> startStreaming() async {
    final LiveStreamController? liveStreamController = _controller;

    if (liveStreamController == null) {
      showInSnackBar('Error: create a camera controller first.');
      return;
    }

    try {
      await liveStreamController.startStreaming(
          streamKey: config.streamKey, url: config.rtmpUrl);
    } catch (error) {
      if (error is PlatformException) {
        print("Error: failed to start stream: ${error.message}");
      } else {
        print("Error: failed to start stream: $error");
      }
    }
  }

  Future<void> stopStreaming() async {
    final LiveStreamController? liveStreamController = _controller;

    if (liveStreamController == null) {
      showInSnackBar('Error: create a camera controller first.');
      return;
    }

    try {
      liveStreamController.stopStreaming();
    } catch (error) {
      if (error is PlatformException) {
        _showDialog(
            context, "Error", "Failed to stop stream: ${error.message}");
      } else {
        _showDialog(context, "Error", "Failed to stop stream: $error");
      }
    }
  }

  void onSwitchCameraButtonPressed() {
    switchCamera().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void onToggleMicrophoneButtonPressed() {
    toggleMicrophone().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void onStartStreamingButtonPressed() {
    startStreaming().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void onStopStreamingButtonPressed() {
    stopStreaming().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Widget buildPreview({required LiveStreamController controller}) {
    // Wait for [LiveStreamController.create] to finish.
    return FutureBuilder<int>(
        future: textureId,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (!snapshot.hasData) {
            // while data is loading:
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return CameraPreview(controller: controller);
          }
        });
  }
}

Future<void> _showDialog(
    BuildContext context, String title, String description) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(description),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Dismiss'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
