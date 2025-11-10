import 'package:dasar/Layout/Widget/ClockPicker/Layout/circularTimePicker.dart';
import 'package:dasar/controller/sleepSave.dart';
import 'package:flutter/material.dart';

class SleepMode extends StatefulWidget {
  const SleepMode({super.key});

  @override
  State<SleepMode> createState() => _SleepModeState();
}

class _SleepModeState extends State<SleepMode> {
  bool _airplaneMode = false;
  bool _silenceMode = false;
  double _hourStart = 0.0;
  double _hourEnd = 6.0;
  
  @override
  void initState() {
    super.initState();
    _loadSavedSleep();
  }

  Future<void> _loadSavedSleep() async {
    Sleepsave sleep = Sleepsave(
      hourStart: 0,
      hourEnd: 0,
      airplaneMode: false,
      silenceMode: false,
    );

    Map<String, dynamic>? data = await sleep.loadSleep();

    if (data != null) {
      setState(() {
        _hourStart = (data['startTime'] as num).toDouble();
        _hourEnd = (data['endTime'] as num).toDouble();
        _airplaneMode = data['airplane'] as bool;
        _silenceMode = data['silence'] as bool;
      });
    }
  }

  Widget _hourStats(String label, String hour){
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        Text(
          hour,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold
          ),
        )
      ],
    );
  }

  Widget _switch(String label, bool value, void Function(bool) onChanged){
    return ListTile(
      title: Text(label),
      trailing: Switch(value: value,
       onChanged: onChanged
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sleep Mode'),
        actions: [
          TextButton(onPressed: () =>
          Sleepsave(
            hourStart: _hourStart, 
            hourEnd: _hourEnd, 
            airplaneMode: 
            _airplaneMode, 
            silenceMode: _silenceMode).saving(context),
          child: Text('Save')),
          TextButton(onPressed: () =>
          Sleepsave(
            hourStart: _hourStart, 
            hourEnd: _hourEnd, 
            airplaneMode: 
            _airplaneMode, 
            silenceMode: _silenceMode).deleteSleep(context),
          child: Text('Delete'))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
        children: [
            SizedBox(height: 30,),
            Circulartimepicker(startHour: _hourStart, 
            endHour: _hourEnd, 
            onStartHourChanged: (newHour) {
                setState(() {
                  _hourStart = newHour;
              });
            }, 
            onEndHourChanged: (newHour){
              setState(() {
                _hourEnd = newHour;
              });
            }
            ),
            SizedBox(height: 30,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _hourStats('Start',_formatHour(_hourStart)),
                SizedBox(width: 30,),
                _hourStats('End',_formatHour(_hourEnd))
              ],
            ),
            SizedBox(height: 20,),
            _switch(
              'Airplane mode',
              _airplaneMode ,
              (val) {
                setState(() {
                  _airplaneMode = val;
                });
              }
            ),
            _switch(
              'Silence mode',
              _silenceMode,
              (val) {
                setState(() {
                  _silenceMode= val;
                });
              }
            )
          ],
        ),
      )
    );
  }
  String _formatHour(double hour) {
    final int hours = hour.floor();
    final int minutes = ((hour - hours) * 60).round();
    final String hourStr = hours.toString().padLeft(2, '0');
    final String minStr = minutes.toString().padLeft(2, '0');
    return '$hourStr:$minStr';
  }
}