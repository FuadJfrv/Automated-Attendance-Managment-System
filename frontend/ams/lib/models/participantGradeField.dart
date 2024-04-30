import 'dart:convert';

import 'package:ams/models/participantMeeting.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class ParticipantGradeField extends StatefulWidget {
  final int sessionId;
  final String? participantEmail;
  const ParticipantGradeField({super.key, required this.sessionId, required this.participantEmail});

  @override
  State<ParticipantGradeField> createState() => _ParticipantGradeFieldState();
}

class _ParticipantGradeFieldState extends State<ParticipantGradeField> {
  List<ParticipantMeeting> meetings = [];

  void getPreviousMeetings() async {

    final response = await http.get(
      //Uri.parse("http://10.0.2.2:5000/api/v1/session/${widget.sessionId}"),
      Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/session/${widget.sessionId}/meetings/participant/${widget.participantEmail}"),
    );

    final data = jsonDecode(response.body);
    List<ParticipantMeeting> meetingsTemp = [];

    for (var participantMeeting in data) {
      if (participantMeeting['meeting']['complete'] == true) {
        DateTime startTime = DateTime.parse(participantMeeting['meeting']['startTime']);
        DateTime endTime = DateTime.parse(participantMeeting['meeting']['endTime']);
        ParticipantMeetingStatus status = ParticipantMeetingStatus.fromString(participantMeeting['status']);

        var newMeeting = ParticipantMeeting(startTime, endTime, status);
        meetingsTemp.add(newMeeting);
      }
    }


    setState(() {
      meetings = meetingsTemp;
    });
  }

  Color getAttendanceColor(int percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage <= 50) return Colors.red;

    // Calculate green and red channel values based on the percentage
    int green = (255 * (percentage / 90)).round(); // Max green at 90%
    int red = (255 * ((90 - percentage) / 40)).round(); // Red decreases after 50%

    return Color.fromARGB(255, red, green, 0);
  }

  int calculateAttendancePercentage() {
    if (meetings.isEmpty) {
      return 0; // Return 0% if there are no meetings to avoid division by zero.
    }

    int totalPossiblePoints = meetings.length * 100; // Maximum points if attended all meetings as 'present'.
    int earnedPoints = 0;

    for (ParticipantMeeting meeting in meetings) {
      switch (meeting.status) {
        case ParticipantMeetingStatus.present:
          earnedPoints += 100; // 100% points for being present
          break;
        case ParticipantMeetingStatus.late:
          earnedPoints += 50; // 50% points for being late
          break;
        case ParticipantMeetingStatus.absent:
        // 0% points for being absent, do nothing
          break;
      }
    }

    return ((earnedPoints / totalPossiblePoints) * 100).round(); // Calculate percentage based on earned points
  }


  @override
  void initState() {
    super.initState();
    getPreviousMeetings();
  }

  @override
  Widget build(BuildContext context) {
    int attendancePercentage = calculateAttendancePercentage(); // Calculate the percentage
    Color attendanceColor = getAttendanceColor(attendancePercentage); // Get color based on percentage
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Grade ", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: attendanceColor, borderRadius: BorderRadius.circular(20)),
            child: Text("$attendancePercentage%", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
