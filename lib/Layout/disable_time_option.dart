import 'package:dasar/Layout/disable_time_layout.dart';
import 'package:dasar/Services/save_json.dart';
import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:dasar/Layout/Widget/button.dart';


class DisableTimeOption extends StatefulWidget {
  final Map<String, dynamic>? applist;

  const DisableTimeOption({super.key, this.applist});

  @override
  State<DisableTimeOption> createState() => _DisableTimeOptionState();
}

class _DisableTimeOptionState extends State<DisableTimeOption> {
  List<AppInfo> apps = [];
  bool isLoading = true;
  Map<String, bool> selectedApps = {}; // track checkbox

  TimeOfDay startTime = TimeOfDay(hour: 23, minute: 30);
  TimeOfDay endTime = TimeOfDay(hour: 7, minute: 0);
  final title = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchInstalledApps();
  }

  Future<void> fetchInstalledApps() async {
    if (widget.applist == null) {
      setState(() => isLoading = false);
      return;
    }

    List<AppInfo> fetchedApps = [];

    for (String key in widget.applist!.keys) {
      try {
        AppInfo? app = await InstalledApps.getAppInfo(key);
        if (app != null) fetchedApps.add(app);
      } catch (e) {
        print("Error fetching app $key: $e");
      }
    }

    setState(() {
      apps = fetchedApps;
      isLoading = false;
    });
  }

  Future<void> _pickTime({required bool isStart}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? startTime : endTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  Future<void> savingFunc(BuildContext context) async {
  List<String> selectedOnly = widget.applist!.entries
    .where((entry) => entry.value)
    .map((entry) => entry.key)
    .toList();

    final String startTimeString = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final String endTimeString = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    Map<String, dynamic> apps = {
      'titleName' : title.text,
      'startTime' : startTimeString,
      'endTime' : endTimeString,
      'apps' : selectedOnly
    };

    bool result = await saveSchedule(apps);

    if(result){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfull saving')),
      );
      Navigator.push(context, MaterialPageRoute(builder: (context) => DisableTimeLayout()));
    } else {
            ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something Wrong. Please send to Github Issue')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set to Disable (With Time)'),
        actions: [
          IconButton(
            onPressed: () => savingFunc(context),
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(
                labelText: 'Enter this Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Button(
              name: "Start Time",
              nav: () => _pickTime(isStart: true),
              height: 60,
              value: "${startTime.hour}:${startTime.minute}",
            ),
            const SizedBox(height: 10),
            Button(
              name: "End Time",
              nav: () => _pickTime(isStart: false),
              height: 60,
              value: "${endTime.hour}:${endTime.minute}",
            ),
            const SizedBox(height: 20),
            Text("Apps selection",
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),
            ),
            if (widget.applist != null)
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: ListView.builder(
                        itemCount: apps.length,
                        itemBuilder: (context, index) {
                          final app = apps[index];
                          return ListTile(
                            title: Text(app.name),
                            subtitle: Text(app.packageName),
                          );
                        },
                      ),
                    ),
            
          ],
        ),
      ),
    );
  }
}
