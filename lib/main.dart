import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui'; // Diperlukan untuk DartPluginRegistrant

import 'package:dasar/Services/sleepTask.dart';
import 'package:flutter/material.dart';
import 'package:dasar/Layout/home.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // <-- TAMBAHKAN
import 'package:path_provider/path_provider.dart';
import 'package:root_plus/root_plus.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- TAMBAHKAN
import 'package:window_size/window_size.dart';

bool hasRoot = false; // Global untuk UI isolate

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    setWindowMinSize(const Size(600, 800));
  }

  // Minta akses root dan simpan statusnya
  if (Platform.isAndroid) {
    hasRoot = await RootPlus.requestRootAccess();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasRoot', hasRoot); // Simpan status root
  }

  // Inisialisasi servis
  await initializeService();

  // HAPUS BAGIAN INI:
  // Logika tidak boleh dijalankan di UI isolate
  // final service = FlutterBackgroundService();
  // service.on('runLogic').listen((event) {
  //   runBackgroundTask();
  //   runSleepTask();
  // });

  runApp(const MyApp());
}

// FUNGSI BARU DARI CONTOH:
// Ini akan membuat servis Anda berjalan sebagai foreground service
// dengan notifikasi, sehingga lebih stabil dan tidak mudah dimatikan.
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  // Konfigurasi notifikasi (dari contoh Anda)
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.low, // atur ke low agar tidak mengganggu
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'), // pastikan Anda punya icon ini
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Konfigurasi servis
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // Fungsi ini akan dieksekusi di background isolate
      onStart: onStart,

      autoStart: true,
      isForegroundMode: true, // WAJIB true untuk tugas jangka panjang

      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'App Service',
      initialNotificationContent: 'Initializing...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      // onBackground: onIosBackground, // Anda bisa tambahkan ini jika perlu
    ),
  );
}

// FUNGSI LAMA ANDA (startBackgroundService), mungkin tidak perlu lagi
// karena autoStart sudah true.
void startBackgroundService() {
  final service = FlutterBackgroundService();
  service.startService();
}

// ENTRY POINT UNTUK BACKGROUND ISOLATE
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // WAJIB: Inisialisasi plugin di isolate baru ini
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  // Ambil status root yang disimpan dari main isolate
  final prefs = await SharedPreferences.getInstance();
  hasRoot = prefs.getBool('hasRoot') ?? false;

  // Opsional: tampilkan notifikasi (dari contoh)
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    // Mulai timer untuk menjalankan tugas Anda
    Timer.periodic(const Duration(minutes: 1), (timer) async {
      // Perbarui notifikasi agar pengguna tahu servis berjalan
      flutterLocalNotificationsPlugin.show(
        888,
        'App Service',
        'Running tasks ${DateTime.now()}',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'my_foreground',
            'MY FOREGROUND SERVICE',
            icon: 'ic_bg_service_small',
            ongoing: true,
          ),
        ),
      );

      debugPrint('BACKGROUND SERVICE: Menjalankan tugas...');

      // PANGGIL LOGIKA ANDA LANGSUNG DI SINI
      await runBackgroundTask();
      await runSleepTask();
    });
  }
}

// FUNGSI LOGIKA ANDA (Tidak berubah, kecuali 'print' menjadi 'debugPrint')
Future<void> runBackgroundTask() async {
  final now = DateTime.now();
  final directory = await getApplicationDocumentsDirectory();
  final files = directory.listSync().where((f) => f.path.endsWith('.json'));

  for (var file in files) {
    try {
      final content = await File(file.path).readAsString();
      if (content.isEmpty) continue;

      final data = jsonDecode(content);
      final apps = data['apps'];
      if (apps is! List) continue;

      final startParts = data['startTime'].split(':');
      final endParts = data['endTime'].split(':');

      DateTime start = DateTime(now.year, now.month, now.day,
          int.parse(startParts[0]), int.parse(startParts[1]));
      DateTime end = DateTime(now.year, now.month, now.day,
          int.parse(endParts[0]), int.parse(endParts[1]));

      if (end.isBefore(start)) {
        if (now.isBefore(start)) {
          start = start.subtract(const Duration(days: 1));
        } else {
          end = end.add(const Duration(days: 1));
        }
      }

      if (now.isAfter(start) && now.isBefore(end)) {
        debugPrint("Time is within range. Disabling apps: $apps");
        await disableApps(apps);
      } else {
        debugPrint("Time is outside range. Enabling apps: $apps");
        await enableApps(apps);
      }
    } catch (e) {
      debugPrint("Error processing file ${file.path}: $e");
    }
  }
}

Future<void> disableApps(List<dynamic> apps) async {
  if (!hasRoot) {
    debugPrint("No root access. Cannot disable apps.");
    return;
  }

  for (var pkg in apps) {
    try {
      await RootPlus.executeRootCommand('pm hide $pkg');
      debugPrint("Disabled $pkg");
    } on RootCommandException catch (e) {
      debugPrint('Command failed on $pkg: ${e.message}');
    }
  }
}

Future<void> enableApps(List<dynamic> apps) async {
  if (!hasRoot) {
    debugPrint("No root access. Cannot disable apps.");
    return; // Perbaikan: harusnya 'return' di sini
  }

  for (var pkg in apps) {
    try {
      await RootPlus.executeRootCommand('pm unhide $pkg');
      debugPrint("Enabled $pkg");
    } on RootCommandException catch (e) {
      debugPrint('Command failed on $pkg: ${e.message}');
    }
  }
}

// UI ANDA (Tidak berubah)
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