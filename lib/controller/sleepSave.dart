import 'dart:convert';
import 'dart:io';

import 'package:dasar/Layout/disable_time_layout.dart';
import 'package:dasar/Services/save_json.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';


class Sleepsave {
  double hourStart;
  double hourEnd;
  bool airplaneMode;
  bool silenceMode;

  Sleepsave({
    required this.hourStart,
    required this.hourEnd,
    required this.airplaneMode,
    required this.silenceMode,
  });

  Future<void> saving(BuildContext context) async {
    Map<String, dynamic> apps = {
      'startTime': hourStart,
      'endTime': hourEnd,
      'airplane': airplaneMode,
      'silence': silenceMode,
    };

    bool result = await saveSleep(apps);

    if (!context.mounted) return; // safety jika widget sudah disposed

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successful saving')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong. Please report.')),
      );
    }
  }

  Future<Map<String, dynamic>?> loadSleep() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/sleep/sleep.json');

    if (!await file.exists()) return null; // tidak ada file

    final jsonString = await file.readAsString();
    return jsonDecode(jsonString);
  } catch (e) {
    return null;
  }
}
  Future<void> deleteSleep(BuildContext context) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/sleep/sleep.json');

      if (await file.exists()) {
        await file.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successful Deleting')),
        );
      }
    } catch (e) {
      print("Gagal menghapus file sleep.json: $e");
    }
  }

  // Reset data tanpa menghapus file
  void disableSleep() {
    hourStart = 0.0;
    hourEnd = 6.0;
    airplaneMode = false;
    silenceMode = false;
  }
}
