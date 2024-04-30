import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AttendanceRecorded extends StatefulWidget {
  final String participantEmail;
  final int meetingId;
  const AttendanceRecorded({super.key, required this.participantEmail, required this.meetingId});

  @override
  State<AttendanceRecorded> createState() => _AttendanceRecordedState();
}

class _AttendanceRecordedState extends State<AttendanceRecorded> {

  void recordParticipant () async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.put(
      Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/meeting/${widget.meetingId}/record/${prefs.getString('participantEmail')}"),
    );
    print(response.body);
  }

  @override
  void initState() {
    super.initState();
    recordParticipant();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
        crossAxisAlignment: CrossAxisAlignment.center, // Center the content horizontally
        children: <Widget>[
          // Padding for the text at the top
          const Padding(
            padding: EdgeInsets.only(top: 40.0, bottom: 20.0),
            child: Center(
              child: Text(
                "Attendance Recorded!",
                style: TextStyle(
                  fontSize: 40.0,
                ),
              ),
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.check_box,
            size: 300.0,
            color: Colors.green,
          ),
          const Spacer(),
          SizedBox(
            width: 150,
            height: 75,
            child: ElevatedButton(
              onPressed: () {
                  return context.go("/participant/${widget.participantEmail}");
              },
              child: const Text("Return", style: TextStyle(fontSize: 24),),
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
