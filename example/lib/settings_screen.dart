import 'package:apivideo_live_stream/apivideo_live_stream.dart';
import 'package:apivideo_live_stream_example/types/channel.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import 'alert/radio_alert_widget.dart';
import 'alert/text_alert_widget.dart';
import 'types/params.dart';
import 'types/resolution.dart';
import 'types/sample_rate.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key, required this.params}) : super(key: key);
  final Params params;

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int resultAlert = -1;

  List<int> fpsList = [24, 30];
  List<int> audioBitrateList = [32000, 64000, 128000, 192000];

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
                    value: Text(widget.params.getResolutionToString()),
                    onPressed: (BuildContext context) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return RadioAlertWidget(
                                title: "Resolutions",
                                values: resolutionsToPrettyString());
                          }).then((value) {
                        if (value != null) {
                          setState(() {
                            widget.params.video.resolution =
                                Resolution.values[value];
                          });
                        }
                      });
                    },
                  ),
                  SettingsTile(
                    title: Text('Framerate'),
                    value: Text(widget.params.video.fps.toString()),
                    onPressed: (BuildContext context) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return RadioAlertWidget(
                              title: "Framerate",
                              values: fpsList.map((e) => e.toString()).toList(),
                            );
                          }).then((value) {
                        if (value != null) {
                          setState(() {
                            widget.params.video.fps = fpsList[value];
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
                                value: (widget.params.video.bitrate / 1024)
                                    .toDouble(),
                                onChanged: (newValue) {
                                  setState(() {
                                    widget.params.video.bitrate =
                                        (newValue.roundToDouble() * 1024)
                                            .toInt();
                                  });
                                },
                                min: 500,
                                max: 10000,
                              ),
                              Text('${widget.params.video.bitrate}')
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
                    value: Text(widget.params.getChannelToString()),
                    onPressed: (BuildContext context) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return RadioAlertWidget(
                              title: "Number of channels",
                              values: channelsToPrettyString(),
                            );
                          }).then((value) {
                        if (value != null) {
                          setState(() {
                            widget.params.audio.channel = Channel.values[value];
                          });
                        }
                      });
                    },
                  ),
                  SettingsTile(
                    title: Text('Bitrate'),
                    value: Text(widget.params.getBitrateToString()),
                    onPressed: (BuildContext context) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return RadioAlertWidget(
                                title: "Bitrate",
                                values: audioBitrateList
                                    .map((e) => "${e / 1000} Kbps")
                                    .toList());
                          }).then((value) {
                        if (value != null) {
                          setState(() {
                            widget.params.audio.bitrate =
                                audioBitrateList[value];
                          });
                        }
                      });
                    },
                  ),
                  SettingsTile(
                    title: Text('Sample rate'),
                    value: Text(widget.params.getSampleRateToString()),
                    onPressed: (BuildContext context) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return RadioAlertWidget(
                                title: "Sample rate",
                                values: sampleRatesToPrettyString());
                          }).then((value) {
                        if (value != null) {
                          setState(() {
                            widget.params.audio.sampleRate =
                            SampleRate.values[value];
                          });
                        }
                      });
                    },
                  ),
                  SettingsTile.switchTile(
                    title: Text('Enable echo canceler'),
                    initialValue: widget.params.audio.enableEchoCanceler,
                    onToggle: (bool value) {
                      setState(() {
                        widget.params.audio.enableEchoCanceler = value;
                      });
                    },
                  ),
                  SettingsTile.switchTile(
                    title: Text('Enable noise suppressor'),
                    initialValue: widget.params.audio.enableNoiseSuppressor,
                    onToggle: (bool value) {
                      setState(() {
                        widget.params.audio.enableNoiseSuppressor = value;
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
                      value: Text(widget.params.rtmpUrl ??
                          "rtmp://broadcast.api.video/s/"),
                      onPressed: (BuildContext context) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return TextAlertWidget(
                                  title: "RTMP endpoint",
                                  decoration: widget.params.rtmpUrl ??
                                      "rtmp://broadcast.api.video/s/");
                            }).then((value) => {
                              setState(() {
                                widget.params.rtmpUrl = value;
                              }),
                            });
                      }),
                  SettingsTile(
                      title: Text('Stream key'),
                      value: Text(widget.params.streamKey),
                      onPressed: (BuildContext context) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return TextAlertWidget(
                                  title: "Stream key",
                                  decoration: widget.params.streamKey);
                            }).then((value) => {
                              setState(() {
                                widget.params.streamKey = value;
                              }),
                            });
                      }),
                ],
              )
            ],
          )),
    );
  }
}
