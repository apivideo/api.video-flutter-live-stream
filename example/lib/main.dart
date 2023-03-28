import 'package:apivideo_live_stream/apivideo_live_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'My live stream app'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  late final ApiVideoLiveStreamController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Fills the whole view
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
            _controlRowWidget(),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    _controller = createLiveStreamController();
    _controller.initialize().catchError((e) {
      print('Failed to initialize controller: $e');
    });
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  ApiVideoLiveStreamController createLiveStreamController() {
    return ApiVideoLiveStreamController(
        initialAudioConfig: AudioConfig(),
        initialVideoConfig: VideoConfig.withDefaultBitrate(),
        onConnectionSuccess: () {
          print('Connection succeeded');
        },
        onConnectionFailed: (error) {
          print('Connection failed: $error');
          if (mounted) {
            setIsStreaming(false);
          }
        },
        onDisconnection: () {
          print('Disconnected');
          if (mounted) {
            setIsStreaming(false);
          }
        });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _controller.stop();
    } else if (state == AppLifecycleState.resumed) {
      _controller.startPreview();
    }
  }

  /// Keeps the streaming state in sync with the controller.
  var _isStreaming = false;

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _controlRowWidget() {
    final ApiVideoLiveStreamController? controller = _controller;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.fiber_manual_record),
          color: Colors.red,
          onPressed: controller != null && !_isStreaming
              ? onStartStreamingButtonPressed
              : null,
        ),
        IconButton(
            icon: const Icon(Icons.stop),
            color: Colors.red,
            onPressed: controller != null && _isStreaming
                ? onStopStreamingButtonPressed
                : null),
      ],
    );
  }

  void onStartStreamingButtonPressed() {
    startStreaming().then((_) {
      if (mounted) {
        setIsStreaming(true);
      }
    }).catchError((error) {
      if (error is PlatformException) {
        print("Error: failed to start stream: ${error.message}");
      } else {
        print("Error: failed to start stream: $error");
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
        print("Error: failed to stop stream: ${error.message}");
      } else {
        print("Error: failed to stop stream: $error");
      }
    });
  }

  Future<void> startStreaming() async {
    final ApiVideoLiveStreamController? controller = _controller;

    if (controller == null) {
      print('Error: create a camera controller first.');
      return;
    }

    await controller.startStreaming(streamKey: 'YOUR_STREAM_KEY');
  }

  Future<void> stopStreaming() async {
    final ApiVideoLiveStreamController? controller = _controller;

    if (controller == null) {
      print('Error: create a camera controller first.');
      return;
    }

    await controller.stopStreaming();
  }

  void setIsStreaming(bool isStreaming) {
    setState(() {
      _isStreaming = isStreaming;
    });
  }
}
