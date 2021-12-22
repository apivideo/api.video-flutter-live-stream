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
                                values: resolutionsToPrettyString());
                          }).then((value) {
                        setState(() {
                          widget.params.video.resolution =
                              Resolution.values[value];
                        });
                      });
                    },
                  ),
                  SettingsTile(
                    title: 'Framerate',
                    subtitle: widget.params.video.fps.toString(),
                    onPressed: (BuildContext context) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return RadioAlertWidget(
                              title: "Framerate",
                              values: fpsList.map((e) => e.toString()).toList(),
                            );
                          }).then((value) {
                        setState(() {
                          widget.params.video.fps = fpsList[value];
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
                              values: channelsToPrettyString(),
                            );
                          }).then((value) {
                        setState(() {
                          widget.params.audio.channel = Channel.values[value];
                        });
                      });
                    },
                  ),
                  SettingsTile(
                    title: 'Bitrate',
                    subtitle: widget.params.getBitrateToString(),
                    onPressed: (BuildContext context) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return RadioAlertWidget(
                                title: "Bitrate",
                                values: audioBitrateList
                                    .map((e) => "${e.toString()} bps")
                                    .toList());
                          }).then((value) {
                        setState(() {
                          widget.params.audio.bitrate = audioBitrateList[value];
                        });
                      });
                    },
                  ),
                  SettingsTile(
                    title: 'Sample rate',
                    subtitle: widget.params.getSampleRateToString(),
                    onPressed: (BuildContext context) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return RadioAlertWidget(
                                title: "Sample rate",
                                values: sampleRatesToPrettyString());
                          }).then((value) {
                        setState(() {
                          widget.params.audio.sampleRate =
                              SampleRate.values[value];
                        });
                      });
                    },
                  ),
                  SettingsTile.switchTile(
                    title: 'Enable echo canceler',
                    switchValue: widget.params.audio.enableEchoCanceler,
                    onToggle: (bool value) {
                      setState(() {
                        widget.params.audio.enableEchoCanceler = value;
                      });
                    },
                  ),
                  SettingsTile.switchTile(
                    title: 'Enable noise suppressor',
                    switchValue: widget.params.audio.enableNoiseSuppressor,
                    onToggle: (bool value) {
                      setState(() {
                        widget.params.audio.enableNoiseSuppressor = value;
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
                                  decoration: widget.params.rtmpUrl ??
                                      "rtmp://broadcast.api.video/s/");
                            }).then((value) => {
                              setState(() {
                                widget.params.rtmpUrl = value;
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
