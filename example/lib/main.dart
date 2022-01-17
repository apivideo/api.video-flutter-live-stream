import 'package:apivideo_live_stream/apivideo_live_stream.dart';
import 'package:apivideo_live_stream_example/settings_screen.dart';
import 'package:apivideo_live_stream_example/types/params.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'constants.dart';

const permissions = [Permission.camera, Permission.microphone];

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(home: LiveViewPage());
  }
}

class LiveViewPage extends StatefulWidget {
  const LiveViewPage({Key? key}) : super(key: key);

  @override
  _LiveViewPageState createState() => new _LiveViewPageState();
}

class _LiveViewPageState extends State<LiveViewPage> {
  final ButtonStyle buttonStyle =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

  bool _isStreaming = false;
  String _liveButtonTitle = "Start";
  String _rtmpStreamKey = '';
  Params params = Params();
  final LiveStreamController _controller =
      LiveStreamController(onConnectionError: (error) {
    // TODO: change live button state
  });

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Center(
                child: SizedBox(
                    height: 400,
                    child: CameraContainer(
                        controller: _controller,
                        initialVideoParameters: params.video,
                        initialAudioParameters: params.audio))),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  style: buttonStyle,
                  onPressed: () {
                    _controller.switchCamera();
                  },
                  child: const Text('switch'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  style: buttonStyle,
                  onPressed: _toggleStream,
                  child: Text('$_liveButtonTitle'),
                ),
              ],
            ),
            Center(
              child: Text('$_rtmpStreamKey'),
            )
          ],
        ),
      ),
    );
  }

  void _toggleStream() {
    setState(() {
      if (_isStreaming) {
        print("Stop Stream");
        _liveButtonTitle = "Start";
        _isStreaming = false;
        _controller.stopStreaming();
      } else {
        print("Start Stream");
        _liveButtonTitle = "Stop";
        _isStreaming = true;
        _controller.startStreaming(
            streamKey: params.streamKey, url: params.rtmpUrl);
      }
    });
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
            builder: (context) => SettingsScreen(params: params)));
    setState(() {
      _rtmpStreamKey = params.streamKey;
    });
    _controller.setVideoParameters(params.video);
    _controller.setAudioParameters(params.audio);
  }
}

class CameraContainer extends StatelessWidget {
  final LiveStreamController controller;
  final VideoParameters initialVideoParameters;
  final AudioParameters initialAudioParameters;

  CameraContainer(
      {required this.controller,
      required this.initialVideoParameters,
      required this.initialAudioParameters});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: _requestPermission(permissions),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            // while data is loading:
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final hasPermissionsAccepted = snapshot.data!;
            if (hasPermissionsAccepted) {
              return CameraPreview(
                  controller: controller,
                  initialVideoParameters: initialVideoParameters,
                  initialAudioParameters: initialAudioParameters);
            } else {
              return Center(
                  child: Text(
                      "Permissions for Camera and Microphone are required"));
            }
          }
        });
  }

  Future<bool> _requestPermission(List<Permission> permissions) async {
    final statuses = await permissions.request();

    var numOfPermissionsGranted = 0;
    statuses.forEach((permission, status) {
      if (status == PermissionStatus.granted) {
        print('$permission permission Granted');
        numOfPermissionsGranted++;
      } else if (status == PermissionStatus.denied) {
        print('$permission permission denied');
      } else if (status == PermissionStatus.permanentlyDenied) {
        print('$permission permission Permanently Denied');
      }
    });
    if (numOfPermissionsGranted >= permissions.length) {
      return true;
    } else {
      return false;
    }
  }
}
