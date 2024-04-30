import 'package:flutter/material.dart';

class Recorded extends StatefulWidget {
  const Recorded({super.key});

  @override
  State<Recorded> createState() => _RecordedState();
}

class _RecordedState extends State<Recorded> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Attendance recorded", style: TextStyle(fontSize: 32, color: Colors.green),)),
    );
  }
}
