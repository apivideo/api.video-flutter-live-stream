import 'package:apivideolivestream_example/Alert/RadioAlertWidget.dart';
import 'package:apivideolivestream_example/Alert/TextAlertWidget.dart';
import 'package:apivideolivestream_example/Model/AudioBitrate.dart';
import 'package:apivideolivestream_example/Model/Channel.dart';
import 'package:apivideolivestream_example/Model/Resolution.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import 'Model/AudioSampleRate.dart';
import 'Model/Params.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key, required this.params}) : super(key: key);
  final Params params;

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isEchoCancelorSwitched = false;
  bool isNoiseSuppressorSwitched = false;
  double _bitrate = 2000;
  int resultAlert = -1;

  get value => true;
  late String codeDialog;
  static String streamkey = "";
  String valueText = "";
  List<String> allFps = ["24", "30", "60", "120", "240"];

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(
                context,
              );
            }),
      ),
      body: Container(
          width: MediaQuery.of(context).size.width,
          child: SettingsList(
            sections: [
              SettingsSection(
                title: 'Video',
                tiles: [
                  SettingsTile(
                    title: 'Resolution',
                    subtitle: widget.params.getResolutionToString(),
                    onPressed: (BuildContext context) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return RadioAlertWidget(
                                title: "Resolutions",
                                values: widget.params.resolution
                                    .getAllResolutionsToString());
                          }).then((value) {
                        setState(() {
                          widget.params.resolution = Resolution.values[value];
                        });
                      });
                    },
                  ),
                  SettingsTile(
                    title: 'Framerate',
                    subtitle: widget.params.fps.toString(),
                    onPressed: (BuildContext context) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return RadioAlertWidget(
                              title: "Framerate",
                              values: allFps,
                            );
                          }).then((value) {
                        //int indexRes = widget.params.getResolutionFromIndex(value) as int;
                        setState(() {
                          widget.params.fps = int.parse(allFps[value]);
                        });
                      });
                    },
                  ),
                  CustomTile(
                    child: Container(
                      child: Column(
                        children: [
                          SettingsTile(
                            title: 'Bitrate',
                          ),
                          Row(
                            children: [
                              Slider(
                                value: _bitrate,
                                onChanged: (newValue) {
                                  setState(() {
                                    _bitrate = newValue.roundToDouble();
                                  });
                                },
                                min: 500,
                                max: 10000,
                              ),
                              Text('${_bitrate.toInt()}')
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SettingsSection(
                title: 'Audio',
                tiles: [
                  SettingsTile(
                    title: "Number of channels",
                    subtitle: widget.params.getChannelToString(),
                    onPressed: (BuildContext context) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return RadioAlertWidget(
                              title: "Number of channels",
                              values: widget.params.channel
                                  .getAllChannelsToString(),
                            );
                          }).then((value) {
                        //int indexRes = widget.params.getResolutionFromIndex(value) as int;
                        setState(() {
                          widget.params.channel = Channel.values[value];
                        });
                      });
                    },
                  ),
                  SettingsTile(
                    title: 'Bitrate',
                    subtitle: widget.params.getAudioBitrateToString(),
                    onPressed: (BuildContext context) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return RadioAlertWidget(
                                title: "Bitrate",
                                values: widget.params.audioBitrate
                                    .getAllAudioBitratesToString());
                          }).then((value) {
                        setState(() {
                          widget.params.audioBitrate =
                              AudioBitrate.values[value];
                        });
                      });
                    },
                  ),
                  SettingsTile(
                    title: 'Sample rate',
                    subtitle: widget.params.getAudioSampleRateToString(),
                    onPressed: (BuildContext context) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return RadioAlertWidget(
                                title: "Sample rate",
                                values: widget.params.audioSampleRate
                                    .getAllAudioSampleRatesToString());
                          }).then((value) {
                        setState(() {
                          widget.params.audioSampleRate =
                              AudioSampleRate.values[value];
                        });
                      });
                    },
                  ),
                  SettingsTile.switchTile(
                    title: 'Enable echo canceler',
                    switchValue: widget.params.isEchocanceled,
                    onToggle: (bool value) {
                      setState(() {
                        widget.params.isEchocanceled = value;
                      });
                    },
                  ),
                  SettingsTile.switchTile(
                    title: 'Enable noise suppressor',
                    switchValue: widget.params.isNoiseSuppressed,
                    onToggle: (bool value) {
                      setState(() {
                        widget.params.isNoiseSuppressed = value;
                      });
                    },
                  ),
                ],
              ),
              SettingsSection(
                title: 'Endpoint',
                tiles: [
                  SettingsTile(
                      title: 'RTMP endpoint',
                      subtitle: widget.params.rtmpUrl,
                      onPressed: (BuildContext context) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return TextAlertWidget(
                                  title: "RTMP endpoint",
                                  decoration: widget.params.rtmpUrl);
                            }).then((value) => {
                              setState(() {
                                widget.params.rtmpUrl =
                                    value;
                              }),
                            });
                      }),
                  SettingsTile(
                      title: 'Stream key',
                      subtitle: widget.params.streamKey,
                      onPressed: (BuildContext context) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return TextAlertWidget(
                                  title: "Stream key",
                                  decoration: widget.params.streamKey);
                            }).then((value) => {
                          setState(() {
                            widget.params.streamKey =
                                value;
                          }),
                        });
                      }),
                ],
              )
            ],
          )),
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context, int id) async {
    TextEditingController _textFieldController = TextEditingController();
    late String title;
    late String decoration;
    switch (id) {
      case 0:
        title = 'Select Rtmp endpoint';
        decoration = widget.params.rtmpUrl;
        break;
      case 1:
        title = 'Select Stream Key';
        decoration = streamkey;
        break;
      default:
        break;
    }
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              controller: _textFieldController,
              decoration: InputDecoration(hintText: decoration),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  setState(() {
                    if (valueText != "") {
                      switch (id) {
                        case 0:
                          print("case 0");
                          widget.params.rtmpUrl = valueText;
                          break;
                        case 1:
                          print("case 1");
                          streamkey = valueText;
                          break;
                        default:
                          break;
                      }
                    }
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }
}
