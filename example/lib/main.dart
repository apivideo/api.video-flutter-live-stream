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
  late final ApiVideoLiveStreamController _controller;
  bool _isStreaming = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    _controller = createLiveStreamController();

    _controller.initialize().catchError((e) {
      showInSnackBar(e.toString());
    });
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

  ApiVideoLiveStreamController createLiveStreamController() {
    return ApiVideoLiveStreamController(
      initialAudioConfig: config.audio,
      initialVideoConfig: config.video,
      onConnectionSuccess: () {
        print('Connection succeeded');
      },
      onConnectionFailed: (error) {
        print('Connection failed: $error');
        _showDialog(context, 'Connection failed', '$error');
        if (mounted) {
          setIsStreaming(false);
        }
      },
      onDisconnection: () {
        showInSnackBar('Disconnected');
        if (mounted) {
          setIsStreaming(false);
        }
      },
    );
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
                    child: ApiVideoCameraPreview(controller: _controller),
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
    final ApiVideoLiveStreamController? liveStreamController = _controller;

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
          onPressed: liveStreamController != null && !_isStreaming
              ? onStartStreamingButtonPressed
              : null,
        ),
        IconButton(
            icon: const Icon(Icons.stop),
            color: Colors.red,
            onPressed: liveStreamController != null && _isStreaming
                ? onStopStreamingButtonPressed
                : null),
      ],
    );
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> switchCamera() async {
    final ApiVideoLiveStreamController? liveStreamController = _controller;

    if (liveStreamController == null) {
      showInSnackBar('Error: create a camera controller first.');
      return;
    }

    return await liveStreamController.switchCamera();
  }

  Future<void> toggleMicrophone() async {
    final ApiVideoLiveStreamController? liveStreamController = _controller;

    if (liveStreamController == null) {
      showInSnackBar('Error: create a camera controller first.');
      return;
    }

    return await liveStreamController.toggleMute();
  }

  Future<void> startStreaming() async {
    final ApiVideoLiveStreamController? controller = _controller;

    if (controller == null) {
      print('Error: create a camera controller first.');
      return;
    }

    return await controller.startStreaming(
        streamKey: config.streamKey, url: config.rtmpUrl);
  }

  Future<void> stopStreaming() async {
    final ApiVideoLiveStreamController? controller = _controller;

    if (controller == null) {
      print('Error: create a camera controller first.');
      return;
    }

    return await controller.stopStreaming();
  }

  void onSwitchCameraButtonPressed() {
    switchCamera().then((_) {
      if (mounted) {
        setState(() {});
      }
    }).catchError((error) {
      if (error is PlatformException) {
        _showDialog(
            context, "Error", "Failed to switch camera: ${error.message}");
      } else {
        _showDialog(context, "Error", "Failed to switch camera: $error");
      }
    });
  }

  void onToggleMicrophoneButtonPressed() {
    toggleMicrophone().then((_) {
      if (mounted) {
        setState(() {});
      }
    }).catchError((error) {
      if (error is PlatformException) {
        _showDialog(
            context, "Error", "Failed to toggle mute: ${error.message}");
      } else {
        _showDialog(context, "Error", "Failed to toggle mute: $error");
      }
    });
  }

  void onStartStreamingButtonPressed() {
    startStreaming().then((_) {
      if (mounted) {
        setIsStreaming(true);
      }
    }).catchError((error) {
      if (error is PlatformException) {
        _showDialog(
            context, "Error", "Failed to start stream: ${error.message}");
      } else {
        _showDialog(context, "Error", "Failed to start stream: $error");
      }
    });
  }

  void onStopStreamingButtonPressed() {
    stopStreaming().then((_) {
      if (mounted) {
        setIsStreaming(false);
      }
    }).catchError((error) {
      if (error is PlatformException) {
        _showDialog(
            context, "Error", "Failed to stop stream: ${error.message}");
      } else {
        _showDialog(context, "Error", "Failed to stop stream: $error");
      }
    });
  }

  void setIsStreaming(bool isStreaming) {
    setState(() {
      _isStreaming = isStreaming;
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
