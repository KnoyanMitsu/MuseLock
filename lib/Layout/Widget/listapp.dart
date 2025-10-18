import 'dart:typed_data';
import 'package:flutter/material.dart';

class ListApp extends StatefulWidget {
  final String nameApp;
  final String packageName;
  final Uint8List? iconApp;
  final Function(bool isChecked) onChanged;

  const ListApp({
    super.key,
    required this.nameApp,
    required this.packageName,
    this.iconApp,
    required this.onChanged,
  });

  @override
  State<ListApp> createState() => _ListAppState();
}

class _ListAppState extends State<ListApp> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(widget.nameApp),
      subtitle: Text(widget.packageName),
      value: isChecked,
      onChanged: (bool? value) {
        setState(() {
          isChecked = value ?? false;
        });
        widget.onChanged(isChecked); 
      },
      secondary: widget.iconApp != null
          ? Image.memory(
              widget.iconApp!,
              width: 40,
              height: 40,
            )
          : const Icon(Icons.apps, size: 40),
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}
