import 'package:dasar/Layout/Widget/listapp.dart';
import 'package:dasar/Layout/disable_time_option.dart';
import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';


class AppList extends StatefulWidget {
  final String title;
  const AppList({super.key, required this.title});

  @override
  State<AppList> createState() => _AppListState();
}

class _AppListState extends State<AppList> {
  List<AppInfo> apps = [];
  bool isLoading = true;

  Map<String, bool> selectedApps = {};
  @override
  void initState() {
    super.initState();
    fetchInstalledApps();
  }

  Future<void> fetchInstalledApps() async {
    try {
      List<AppInfo> fetchedApps = await InstalledApps.getInstalledApps(
        excludeSystemApps: true,
        excludeNonLaunchableApps: true,
        withIcon: true,
      );

      setState(() {
        apps = fetchedApps;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching apps: $e");
      setState(() => isLoading = false);
    }
  }
  
  void _sendToApplist(BuildContext context){
    Navigator.push(context, MaterialPageRoute(builder: (context) => DisableTimeOption(applist: selectedApps)));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          TextButton(onPressed: () => _sendToApplist(context), child: Text("Save"))
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final app = apps[index];
                return ListApp(
                  nameApp: app.name,
                  packageName: app.packageName,
                  iconApp: app.icon,
                  onChanged: (isChecked){
                    setState(() {
                      selectedApps[app.packageName] = isChecked;
                    });
                  },
                );
              },
            ),
    );
  }
}
