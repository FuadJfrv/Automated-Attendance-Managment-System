import 'dart:convert';

import 'package:ams/models/participantGradeField.dart';
import 'package:ams/models/participantHistoryCard.dart';
import 'package:ams/models/participantMeeting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ParticipantSessionScreen extends StatefulWidget {
  final int sessionId;
  final String sessionName;
  const ParticipantSessionScreen({super.key, required this.sessionId, required this.sessionName});

  @override
  State<ParticipantSessionScreen> createState() => _ParticipantSessionScreenState();
}

class _ParticipantSessionScreenState extends State<ParticipantSessionScreen> {
  late int activeMeetingId;
  List<ParticipantMeeting> meetings = [];
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<int> getActiveMeetingId() async {
    final response = await http.get(
      //Uri.parse("http://10.0.2.2:5000/api/v1/participant/345@gmail.com/getAllSessions"),
      Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/session/${widget.sessionId}/meetings/active"),
    );
    final data = jsonDecode(response.body);
    return data['id'];
  }

  void getPreviousMeetings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.get(
      //Uri.parse("http://10.0.2.2:5000/api/v1/session/${widget.sessionId}"),
      Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/session/${widget.sessionId}/meetings/participant/${prefs.getString('participantEmail')}"),
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

  @override
  void initState() {
    super.initState();
    getPreviousMeetings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.sessionName)
      ),
      body: FutureBuilder<SharedPreferences>(
        future: _prefs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            // SharedPreferences is now available and can be accessed
            String participantEmail = snapshot.data!.getString('participantEmail') ?? 'default_email@example.com';

            return buildContent(context, participantEmail);
          } else {
            // Handle loading state, error state, etc.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget buildContent(BuildContext context, String participantEmail) {
    return Center(
      child: Column(
        children: [
          ParticipantGradeField(sessionId: widget.sessionId, participantEmail: participantEmail),

          ParticipantHistoryCard(sessionId: widget.sessionId, participantEmail: participantEmail),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 100.0),
            child: SizedBox(
              width: 180,
              height: 80,
              child: ElevatedButton(
                onPressed: () async {
                  activeMeetingId = await getActiveMeetingId();
                  return context.go("/participant/${participantEmail}/session/${widget.sessionId}/${widget.sessionName}/qrScanner/$activeMeetingId");
                },
                child: const Text('Check-In', style: TextStyle(fontSize: 22)),
              ),
            ),
          ),

        ],
      ),
    );
  }

}
