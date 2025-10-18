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
    print("Gagal menyimpan jadwal: $e");
    return false; // gagal
  }
}
