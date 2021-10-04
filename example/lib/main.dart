import 'package:flutter/material.dart';
import 'package:apivideolivestream/apivideolivestream.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Apivideolivestream? controller;
  bool _isStreaming = false;
  String _title = "Start";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style =
        ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Center(
                child: _cameraPreviewWidget(),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    style: style,
                    onPressed: () {
                      Apivideolivestream.switchCamera();
                    },
                    child: const Text('switch'),
                  ),
                  const SizedBox(width: 30),
                  ElevatedButton(
                    style: style,
                    onPressed: _toggleStream,
                    child: Text('$_title'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _toggleStream() {
    setState(() {
      if (_isStreaming) {
        print("Stop Stream");
        _title = "Start";
        _isStreaming = false;
        Apivideolivestream.stopStream();
      } else {
        print("Start Stream");
        _title = "Stop";
        _isStreaming = true;
        Apivideolivestream.startStream();
      }
    });
  }

  Widget _cameraPreviewWidget() {
    final plugin = Apivideolivestream();

    return Container(
      color: Colors.lightBlueAccent,
      child: LiveStreamPreview(
        controller: plugin,
        liveStreamKey: 'd08c582e-e251-4f9e-9894-8c8d69755d45',
        videoResolution: '2160p',
      ),
    );
  }
}
