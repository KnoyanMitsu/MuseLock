import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


Future<bool> saveSchedule(Map<String, dynamic> data) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${data['titleName']}.json';
    final file = File(path);

    final jsonString = jsonEncode(data);
    await file.writeAsString(jsonString);

    return true; // sukses
  } catch (e) {
    return false; // gagal
  }
}

Future<bool> saveSleep(Map<String, dynamic> data) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final folder = Directory('${directory.path}/sleep');

    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    final file = File('${folder.path}/sleep.json');
    await file.writeAsString(jsonEncode(data));

    return true;
  } catch (e) {
    print(e);
    return false;
  }
}

