import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SessionCard extends StatelessWidget {
  SessionCard({
    super.key,
    required this.sessionName,
    this.active = false
  });

  bool active;
  final String sessionName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
      child: Card(
        //color: Color.fromRGBO(255, 240, 255, 1),
        child: SizedBox(
          height: 200,
          child: Center(
            child: Text(
              sessionName,
              style: GoogleFonts.sourceSans3( textStyle: active ? TextStyle(fontSize: 40, color: Colors.greenAccent) : TextStyle(fontSize: 40, color: Colors.black),),
            ),
          ),
        ),
      ),
    );
  }
}
