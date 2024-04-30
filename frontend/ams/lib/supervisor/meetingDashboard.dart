import 'dart:async';
import 'dart:convert';

import 'package:ams/models/participantDashboardStatus.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

import '../models/participantMeeting.dart';



class MeetingDashboard extends StatefulWidget {
  final int sessionId;
  final int meetingId;
  final int windowId;

  const MeetingDashboard({super.key, required this.sessionId, required this.meetingId, required this.windowId});

  @override
  State<MeetingDashboard> createState() => _MeetingDashboardState();
}

class _MeetingDashboardState extends State<MeetingDashboard> {
  List<ParticipantDashboardStatus> participantStatuses = [];
  late Timer _timer;

  late WindowController windowController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getParticipantsStatus();
    });
    statusRefresher();
    windowController = WindowController.fromWindowId(widget.windowId);
  }

  void printReceived() {
    print("MeetingDashboard received ${widget.sessionId} ${widget.meetingId} ${widget.windowId}");
  }

  @override
  void dispose() {
    endMeeting(widget.meetingId);
    _timer.cancel();
    super.dispose();
  }

  void statusRefresher()  {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        getParticipantsStatus();
      });
    });
  }

  void getParticipantsStatus() async {
    try {
      print("${widget.sessionId} ${widget.meetingId}");
      final response = await http.get(
        Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/session/${widget.sessionId}/meeting/${widget.meetingId}/getParticipantsStatus"),
      );
      final data = jsonDecode(response.body);

      List<ParticipantDashboardStatus> statusTemp = [];

      for (var participant in data) {
        ParticipantMeetingStatus status = ParticipantMeetingStatus.fromString(participant['status']);
        var newStatus = ParticipantDashboardStatus(participant['name'], status);
        statusTemp.add(newStatus);
      }

      print(statusTemp);
      setState(() {
        participantStatuses = statusTemp;
      });
    } catch (e) {
      print('Failed to get participants status: $e');
    }
  }


  void endMeeting(int? meetingId) async {
    final response = await http.put(
      Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/session/${widget.sessionId}/meetings/$meetingId/end"),
    );
    windowController.close();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        body: ListView(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 5.0,
                minWidth: 5.0,
                maxHeight: 500.0,
                maxWidth: 300.0,
              ),
              child: Card(
                elevation: 4.0,
                margin: EdgeInsets.all(8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                ),
                child: SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: participantStatuses.length,
                    itemBuilder: (context, index) {
                      // Alternate background color
                      Color backgroundColor = index % 2 == 0 ? Colors.white : Colors.grey[200]!;

                      return Container(
                        color: backgroundColor,
                        child: ListTile(
                          leading: Icon(
                            Icons.access_time_filled,
                            color: participantStatuses[index].status == ParticipantMeetingStatus.present ? Colors.green
                                : participantStatuses[index].status == ParticipantMeetingStatus.late ? Colors.orangeAccent
                                : Colors.red,  // Extended conditional color logic for three statuses
                          ),
                          title: Text(participantStatuses[index].name),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton.large(
                onPressed: () {
                  endMeeting(widget.meetingId);
                  //return context.go("/supervisor/session/${widget.sessionId}");
                },
                backgroundColor: Colors.deepPurple,
                child: const Text("End Meeting", style: TextStyle(fontSize: 24, color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
