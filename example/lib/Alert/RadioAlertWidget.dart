import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RadioAlertWidget extends StatefulWidget {
  final String title;
  final List<String> values;

  const RadioAlertWidget({required this.title, required this.values});

  @override
  _RadioAlertWidgetState createState() => _RadioAlertWidgetState();
}

class _RadioAlertWidgetState extends State<RadioAlertWidget> {
  int _val = 0;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoAlertDialog(
        title: new Text(widget.title),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children:
                      List<Widget>.generate(widget.values.length, (int index) {
                    return RadioListTile<int>(
                      title: Text(widget.values[index]),
                      value: index,
                      groupValue: _val,
                      onChanged: (newValue) {
                        print("radio button cliked");
                        setState(() {
                          _val = int.parse(newValue.toString());
                          print("selected val $_val");
                        });
                      },
                    );
                  }),
                ));
          },
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text("Cancel"),
            onPressed: () {
              setState(() {
                Navigator.pop(context);
              });
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text("Ok"),
            onPressed: () {
              print("selected radio : $_val");
              setState(() {
                Navigator.pop(context, _val);
              });
            },
          )
        ],
      );
    } else {
      return AlertDialog(
        title: Text(widget.title),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  List<Widget>.generate(widget.values.length, (int index) {
                return RadioListTile(
                  title: Text(widget.values[index]),
                  value: index,
                  groupValue: _val,
                  onChanged: (newValue) {
                    setState(() {
                      _val = int.parse(newValue.toString());
                    });
                  },
                );
              }),
            );
          },
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
                Navigator.pop(context, _val);
              });
            },
          ),
        ],
      );
    }
  }
}
