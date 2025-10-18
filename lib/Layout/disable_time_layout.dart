import 'dart:convert';
import 'dart:io';
import 'package:dasar/Layout/applist.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DisableTimeLayout extends StatefulWidget {
  const DisableTimeLayout({super.key});

  @override
  State<DisableTimeLayout> createState() => _DisableTimeLayoutState();
}

class _DisableTimeLayoutState extends State<DisableTimeLayout> {
  List<Map<String, dynamic>> schedules = [];

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory
        .listSync()
        .where((f) => f.path.endsWith('.json'))
        .toList();

    final List<Map<String, dynamic>> loaded = [];

    for (var file in files) {
      try {
        final content = await File(file.path).readAsString();
        final data = jsonDecode(content);

        // Tangani kasus di mana "apps" bisa berupa List atau Map
        List<String> appsList = [];
        final apps = data["apps"];
        if (apps is List) {
          appsList = apps.map((e) => e.toString()).toList();
        } else if (apps is Map) {
          appsList = apps.values.map((e) => e.toString()).toList();
        }

        loaded.add({
          "title": data["titleName"] ?? "Untitled",
          "start": data["startTime"] ?? "-",
          "end": data["endTime"] ?? "-",
          "apps": appsList.join(", "),
          "path": file.path
        });
      } catch (e) {
        debugPrint("Error reading ${file.path}: $e");
      }
    }

    setState(() {
      schedules = loaded;
    });
  }

  void _openDisableTimeOption(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppList(title: "Select to Disable"),
      ),
    ).then((_) => _loadSchedules()); // refresh setelah balik dari AppList
  }

  void _deleteSchedule(String path) async {
    await File(path).delete();
    _loadSchedules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Disable Apps"),
        actions: [
          IconButton(
            onPressed: () => _openDisableTimeOption(context),
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: _loadSchedules,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: schedules.isEmpty
          ? const Center(
              child: Text("No schedules found"),
            )
          : ListView.builder(
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final item = schedules[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.schedule),
                    title: Text(item["title"]),
                    subtitle: Text(
                      "${item["start"]} - ${item["end"]}\n${item["apps"]}",
                      style: const TextStyle(height: 1.4),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteSchedule(item["path"]),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
