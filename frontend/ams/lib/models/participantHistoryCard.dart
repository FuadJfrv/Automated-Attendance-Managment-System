import 'dart:convert';

import 'package:ams/models/participantMeeting.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class ParticipantHistoryCard extends StatefulWidget {
  final int sessionId;
  final String? participantEmail;

  const ParticipantHistoryCard({super.key, required this.sessionId, required this.participantEmail});

  @override
  State<ParticipantHistoryCard> createState() => _ParticipantHistoryCardState();
}

class _ParticipantHistoryCardState extends State<ParticipantHistoryCard> {
  List<ParticipantMeeting> meetings = [];

  void getPreviousMeetings() async {
    final response = await http.get(
      Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/session/${widget.sessionId}/meetings/participant/${widget.participantEmail}"),
    );

    final data = jsonDecode(response.body);
    print(data);
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


  @override
  void initState() {
    super.initState();
    getPreviousMeetings();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 5.0,
        minWidth: 5.0,
        maxHeight: 500.0,
        maxWidth: 600.0,
      ),
      child: Card(
        elevation: 4.0,
        margin: const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Rounded corners
        ),
        child: SizedBox(
          height: 300,
          //width: 300,
          child: ListView.builder(
            itemCount: meetings.length,
            itemBuilder: (context, index) {
              DateTime startTime = meetings[index].startTime;
              DateTime endTime = meetings[index].endTime;

              DateTime adjustedStartTime = startTime.add(const Duration(hours: 4)); // Adjust for timezone
              DateTime adjustedEndTime = endTime.add(const Duration(hours: 4)); // Adjust for timezone

              String formattedDate = DateFormat('yyyy-MM-dd').format(adjustedStartTime);
              String formattedStartTime = DateFormat('HH:mm:ss').format(adjustedStartTime);
              String formattedEndTime = DateFormat('HH:mm:ss').format(adjustedEndTime);

              // Alternate background color
              Color backgroundColor = index % 2 == 0 ? Colors.white : Colors.grey[200]!;

              return Container(
                color: backgroundColor,
                child: ListTile(
                  leading: Tooltip(
                    message: meetings[index].status == ParticipantMeetingStatus.present ? "Present"
                        : meetings[index].status == ParticipantMeetingStatus.late ? "Late" : "Absent", // Extended conditional tooltip message
                    child: Icon(
                      Icons.access_time_filled,
                      color: meetings[index].status == ParticipantMeetingStatus.present ? Colors.green
                          : meetings[index].status == ParticipantMeetingStatus.late ? Colors.orangeAccent : Colors.red,  // Extended conditional color logic
                    ),
                  ),
                  title: Text("Date: $formattedDate, Start time: $formattedStartTime, End time: $formattedEndTime"),
                ),
              );

            },
          ),
        ),
      ),
    );
  }
}
