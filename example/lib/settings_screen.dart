import 'package:apivideo_live_stream_example/utils/audio_bitrate.dart';
import 'package:apivideo_live_stream_example/utils/channel.dart';
import 'package:apivideo_live_stream_example/utils/fps.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import 'types/params.dart';
import 'utils/resolution.dart';
import 'utils/sample_rate.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key, required this.params}) : super(key: key);
  final Params params;

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int resultAlert = -1;

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
                title: Text('Video'),
                tiles: [
                  SettingsTile(
                    title: Text('Resolution'),
                    value: Text(widget.params.videoResolution.toPrettyString()),
                    onPressed: (BuildContext context) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return PickerScreen(
                                title: "Pick a resolution",
                                initialValue: widget.params.videoResolution,
                                values: inflateResolutionsMap());
                          }).then((value) {
                        if (value != null) {
                          setState(() {
                            widget.params.videoResolution = value;
                          });
                        }
                      });
                    },
                  ),
                  SettingsTile(
                    title: Text('Framerate'),
                    value: Text(widget.params.videoFps.toString()),
                    onPressed: (BuildContext context) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return PickerScreen(
                                title: "Pick a frame rate",
                                initialValue: widget.params.videoFps.toString(),
                                values: inflateFpsMap());
                          }).then((value) {
                        if (value != null) {
                          setState(() {
                            widget.params.videoFps = value;
                          });
                        }
                      });
                    },
                  ),
                  CustomSettingsTile(
                    child: Container(
                      child: Column(
                        children: [
                          SettingsTile(
                            title: Text('Bitrate'),
                          ),
                          Row(
                            children: [
                              Slider(
                                value: (widget.params.videoBitrate / 1024)
                                    .toDouble(),
                                onChanged: (newValue) {
                                  setState(() {
                                    widget.params.videoBitrate =
                                        (newValue.roundToDouble() * 1024)
                                            .toInt();
                                  });
                                },
                                min: 500,
                                max: 10000,
                              ),
                              Text('${widget.params.videoBitrate}')
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SettingsSection(
                title: Text('Audio'),
                tiles: [
                  SettingsTile(
                    title: Text("Number of channels"),
                    value: Text(widget.params.audioChannel.toPrettyString()),
                    onPressed: (BuildContext context) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return PickerScreen(
                                title: "Pick the number of channels",
                                initialValue:
                                    widget.params.audioChannel.toPrettyString(),
                                values: inflateChannelsMap());
                          }).then((value) {
                        if (value != null) {
                          setState(() {
                            widget.params.audioChannel = value;
                          });
                        }
                      });
                    },
                  ),
                  SettingsTile(
                    title: Text('Bitrate'),
                    value:
                        Text(bitrateToPrettyString(widget.params.audioBitrate)),
                    onPressed: (BuildContext context) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return PickerScreen(
                                title: "Pick a bitrate",
                                initialValue: bitrateToPrettyString(
                                    widget.params.audioBitrate),
                                values: inflateAudioBitrateMap());
                          }).then((value) {
                        if (value != null) {
                          setState(() {
                            widget.params.audioBitrate = value;
                          });
                        }
                      });
                    },
                  ),
                  SettingsTile(
                    title: Text('Sample rate'),
                    value: Text(sampleRateToPrettyString(
                        widget.params.audioSampleRate)),
                    onPressed: (BuildContext context) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return PickerScreen(
                                title: "Pick a sample rate",
                                initialValue: sampleRateToPrettyString(
                                    widget.params.audioSampleRate),
                                values: inflateSampleRatesMap());
                          }).then((value) {
                        if (value != null) {
                          setState(() {
                            widget.params.audioSampleRate = value;
                          });
                        }
                      });
                    },
                  ),
                  SettingsTile.switchTile(
                    title: Text('Enable echo canceler'),
                    initialValue: widget.params.audioEnableEchoCanceler,
                    onToggle: (bool value) {
                      setState(() {
                        widget.params.audioEnableEchoCanceler = value;
                      });
                    },
                  ),
                  SettingsTile.switchTile(
                    title: Text('Enable noise suppressor'),
                    initialValue: widget.params.audioEnableNoiseSuppressor,
                    onToggle: (bool value) {
                      setState(() {
                        widget.params.audioEnableNoiseSuppressor = value;
                      });
                    },
                  ),
                ],
              ),
              SettingsSection(
                title: Text('Endpoint'),
                tiles: [
                  SettingsTile(
                      title: Text('RTMP endpoint'),
                      value: Text(widget.params.rtmpUrl),
                      onPressed: (BuildContext context) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return EditTextScreen(
                                  title: "Enter RTMP endpoint URL",
                                  initialValue: widget.params.rtmpUrl,
                                  onChanged: (value) {
                                    setState(() {
                                      widget.params.rtmpUrl = value;
                                    });
                                  });
                            });
                      }),
                  SettingsTile(
                      title: Text('Stream key'),
                      value: Text(widget.params.streamKey),
                      onPressed: (BuildContext context) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return EditTextScreen(
                                  title: "Enter stream key",
                                  initialValue: widget.params.streamKey,
                                  onChanged: (value) {
                                    setState(() {
                                      widget.params.streamKey = value;
                                    });
                                  });
                            });
                      }),
                ],
              )
            ],
          )),
    );
  }
}

class PickerScreen extends StatelessWidget {
  const PickerScreen({
    Key? key,
    required this.title,
    required this.initialValue,
    required this.values,
  }) : super(key: key);

  final String title;
  final dynamic initialValue;
  final Map<dynamic, String> values;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text(title),
            tiles: values.keys.map((e) {
              final value = values[e];

              return SettingsTile(
                title: Text(value!),
                onPressed: (_) {
                  Navigator.of(context).pop(e);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class EditTextScreen extends StatelessWidget {
  const EditTextScreen(
      {Key? key,
      required this.title,
      required this.initialValue,
      required this.onChanged})
      : super(key: key);

  final String title;
  final String initialValue;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: SettingsList(
        sections: [
          SettingsSection(title: Text(title), tiles: [
            CustomSettingsTile(
              child: TextField(
                  controller: TextEditingController(text: initialValue),
                  onChanged: onChanged),
            ),
          ]),
        ],
      ),
    );
  }
}
