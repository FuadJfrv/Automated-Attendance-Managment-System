import 'dart:convert';

import 'package:ams/models/participantMeeting.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CsvExporter {

  final int sessionId;
  final List<String> participantEmails;

  CsvExporter(this.sessionId, this.participantEmails);

  List<List<ParticipantMeeting>> participantsMeetingsHistory = [];


  Future<void> getParticipantMeetingsHistory(String participantEmail) async {
    final response = await http.get(
      Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/session/${sessionId}/meetings/participant/${participantEmail}"),
    );

    final data = jsonDecode(response.body);
    List<List<ParticipantMeeting>> participantsMeetingsHistoryTemp = [];
    List<ParticipantMeeting> participantMeetingsHistoryTemp = [];


    for (var participantMeeting in data) {
      if (participantMeeting['meeting']['complete'] == true) {
        DateTime startTime = DateTime.parse(participantMeeting['meeting']['startTime']);
        DateTime endTime = DateTime.parse(participantMeeting['meeting']['endTime']);

        ParticipantMeetingStatus status = ParticipantMeetingStatus.fromString(participantMeeting['status']);

        var newMeeting = ParticipantMeeting(startTime, endTime, status);
        participantMeetingsHistoryTemp.add(newMeeting);
      }
    }

    participantsMeetingsHistoryTemp.add(participantMeetingsHistoryTemp);
  }


  // Future<String> generateCsvData() async {
  //   for (var email in participantEmails) {
  //     await getParticipantMeetingsHistory(email);
  //   }
  //
  //   print(participantsMeetingsHistory);
  //   List<List<dynamic>> rows = [];
  //   List<dynamic> row = [];
  //   row.add("Participant Name");
  //
  //   for (var meeting in meetings) {
  //     row.add("Meeting${meetings.indexOf(meeting) + 1}_Date");
  //     row.add("Participant_Meeting${meetings.indexOf(meeting) + 1}_Status");
  //   }
  //   rows.add(row);
  //
  //   for (var participantEmail in participantEmails ) {
  //     row = [];
  //     row.add(participantEmail);
  //     for (var meeting in meetings) {
  //       row.add(DateFormat('yyyy-MM-dd').format(meeting.startTime.add(const Duration(hours: 4))));
  //       row.add(meeting.status.toString());
  //     }
  //     rows.add(row);
  //   }
  //
  //   String csv = const ListToCsvConverter().convert(rows);
  //   print(csv);
  //   return csv;
  // }
}