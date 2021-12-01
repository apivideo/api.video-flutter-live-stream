import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextAlertWidget extends StatefulWidget {
  final String title;
  final String decoration;

  const TextAlertWidget({required this.title, required this.decoration});

  @override
  _TextAlertWidgetState createState() => _TextAlertWidgetState();
}

class _TextAlertWidgetState extends State<TextAlertWidget> {
  TextEditingController _textFieldController = TextEditingController();
  String valueText = "";

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoAlertDialog(
        title: new Text(widget.title),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Material(
              color: Colors.transparent,
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    if(value !=""){
                      valueText = value;
                    }
                  });
                },
                controller: _textFieldController,
                decoration: InputDecoration(hintText: widget.decoration),
              ),
            );
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
              print("selected radio : $valueText");
              setState(() {
                Navigator.pop(context, valueText);
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
            return TextField(
              onChanged: (value) {
                setState(() {
                  if(value !=""){
                    valueText = value;
                  }
                });
              },
              controller: _textFieldController,
              decoration: InputDecoration(hintText: widget.decoration),
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
                Navigator.pop(context, valueText);
              });
            },
          ),
        ],
      );
    }
  }
}
