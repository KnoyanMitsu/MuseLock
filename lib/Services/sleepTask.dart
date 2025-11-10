
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:root_plus/root_plus.dart';

Future<void> runSleepTask()
async {
  final now = DateTime.now();
  final directory = await getApplicationDocumentsDirectory();

  try{
  final file = File('${directory.path}/sleep/sleep.json');

  if (!await file.exists()) {
    print("File sleep.json tidak ada, diabaikan");
    return; // keluar dari function tanpa error
  }

  final jsonString = await file.readAsString();
  final data = jsonDecode(jsonString);
  final startParts = _formatHour(data['startTime']).split(":");
  final endParts = _formatHour(data['endTime']).split(":");

  final bool airplane = data['airplane'];
  final bool silence = data['silence'];

  DateTime start = DateTime(now.year, now.month, now.day,
    int.parse(startParts[0]), int.parse(startParts[1]));
  DateTime end = DateTime(now.year, now.month, now.day,
    int.parse(endParts[0]), int.parse(endParts[1]));

  if (end.isBefore(start)){
    if (now.isBefore(start)){
      start = start.subtract(const Duration(days: 1));
    } else {
      end = end.add(const Duration(days: 1));
    }
  }

  if (now.isAfter(start) && now.isBefore(end)) {
    print("Sleep");
    await sleepNow(airplane, silence);
  } else {
    print("Morning");
    await morning(airplane, silence);
  }

  }catch(e){
    print(e);
  }
}

Future<void>sleepNow(bool airplane,bool silence) async{
  try{
    if(airplane){
      await RootPlus.executeRootCommand('cmd connectivity airplane-mode enable');
    }

    if(silence){
      await RootPlus.executeRootCommand('settings put global mode_ringer 2');
    }
  // ignore: empty_catches
  } on RootCommandException catch (e){
    
  }
}

Future<void>morning(bool airplane,bool silence) async{
  try{
    if(airplane){
      await RootPlus.executeRootCommand('cmd connectivity airplane-mode disable');
    }

    if(silence){
      await RootPlus.executeRootCommand('settings put global mode_ringer 1');
    }
  // ignore: empty_catches
  } on RootCommandException catch (e){
    
  }
}

String _formatHour(double hour) {
  final int hours = hour.floor();
  final int minutes = ((hour - hours) * 60).round();
  final String hourStr = hours.toString().padLeft(2, '0');
  final String minStr = minutes.toString().padLeft(2, '0');
  return '$hourStr:$minStr';
}
