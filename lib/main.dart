import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:dasar/Layout/home.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:root_plus/root_plus.dart';
import 'package:window_size/window_size.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    setWindowMinSize(const Size(600, 800));
  }
  
  // Selalu panggil initializeService sebelum setup listener
  await initializeService(); 

  // BARU: Siapkan listener di main isolate untuk menerima perintah dari background
  final service = FlutterBackgroundService();
  service.on('runLogic').listen((event) {
    print("Background trigger received. Running task...");
    runBackgroundTask();
  });

  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
      autoStartOnBoot: true,
      
    ),
    iosConfiguration: IosConfiguration(autoStart: true),
  );
  
}

// FUNGSI INI SEKARANG HANYA MENJADI PEMICU
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    // Mengirim sinyal 'runLogic' ke main isolate
    service.invoke('runLogic');
  });
}

// SEMUA LOGIKA BERAT PINDAH KE SINI, DIJALANKAN DI MAIN ISOLATE
Future<void> runBackgroundTask() async {
  final now = DateTime.now();
  final directory = await getApplicationDocumentsDirectory();
  final files = directory.listSync().where((f) => f.path.endsWith('.json'));

  for (var file in files) {
    try {
      final content = await File(file.path).readAsString();
      if (content.isEmpty) continue; // Lewati file JSON yang mungkin kosong

      final data = jsonDecode(content);
      final apps = data['apps'];
      if (apps is! List) continue;

      final startParts = data['startTime'].split(':');
      final endParts = data['endTime'].split(':');

      DateTime start = DateTime(now.year, now.month, now.day,
          int.parse(startParts[0]), int.parse(startParts[1]));
      DateTime end = DateTime(now.year, now.month, now.day,
          int.parse(endParts[0]), int.parse(endParts[1]));
      
      // Logika untuk handle waktu yang melewati tengah malam (misal 23:00 - 07:00)
      if (end.isBefore(start)) {
        if (now.isBefore(start)) {
            start = start.subtract(const Duration(days: 1));
        } else {
            end = end.add(const Duration(days: 1));
        }
      }

      if (now.isAfter(start) && now.isBefore(end)) {
        print("Time is within range. Disabling apps: $apps");
        disableApps(apps);
      } else {
        print("Time is outside range. Enabling apps: $apps");
        enableApps(apps);
      }
    } catch (e) {
      print("Error processing file ${file.path}: $e");
    }
  }
}

void disableApps(List<dynamic> apps) {
  for (var pkg in apps) {
    try {
      RootPlus.executeRootCommand('pm hide $pkg');
    } on RootCommandException catch (e) {
      print('Command failed on $pkg: ${e.message}');
    }
  }
}

void enableApps(List<dynamic> apps) {
  for (var pkg in apps) {
    try {
      RootPlus.executeRootCommand('pm unhide $pkg');
    } on RootCommandException catch (e) {
      print('Command failed on $pkg: ${e.message}');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(title: "Home"),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
    );
  }
}