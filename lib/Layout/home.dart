import 'package:dasar/Layout/sleepMode.dart';
import 'package:dasar/Layout/Widget/button.dart';
import 'package:dasar/Layout/Widget/clock.dart';
import 'package:dasar/Layout/disable_time_layout.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  final String title;
  const Home({super.key, required this.title});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
    void _openSleepMode(BuildContext context){
      Navigator.push(context, MaterialPageRoute(builder: (context) => SleepMode(),));
    }
    void _openDisableTime(BuildContext context){
      Navigator.push(context, MaterialPageRoute(builder:  (context) => DisableTimeLayout()));
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(widget.title),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Clock(),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                    Button(
                      height: 80,
                      name: "Disable apps with time (root)",
                      nav: () => {_openDisableTime(context)},
                      icon: Icons.lock_clock,
                      shadow: 0.4,
                    ),
                  const SizedBox(height: 10),
                    Button(
                      name: "Sleep Mode (root)",
                      nav: () => _openSleepMode(context),
                      icon: Icons.mode_night,
                      shadow: 0.4,
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
