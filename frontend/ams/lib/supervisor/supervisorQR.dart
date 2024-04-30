import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'package:window_manager/window_manager.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';

import '../models/participantDashboardStatus.dart';
import '../models/participantMeeting.dart';


class SupervisorQr extends StatefulWidget {
  final int sessionId;
  final int meetingId;
  final String supervisorEmail;
  final int xPos;
  final int yPos;

  const SupervisorQr({super.key, required this.sessionId, required this.meetingId, required this.supervisorEmail,
  required this.xPos, required this.yPos});

  @override
  State<SupervisorQr> createState() => _SupervisorQrState();
}
const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();
String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

class _SupervisorQrState extends State<SupervisorQr> {
  var qrData = getRandomString(24);
  double progress = 1.0; // Progress of the countdown
  late Timer _timer; // Timer for QR refresh
  late Timer _countdownTimer; // Timer for countdown update
  List<ParticipantDashboardStatus> participantStatuses = [];

  @override
  void initState() {
    super.initState();
    print("QR RECEIVED ${widget.meetingId} ${widget.sessionId} ${widget.supervisorEmail} ${widget.xPos} ${widget.yPos}");
    createQrWindow();
    addQrToMeeting();
    qrRefresher();
    startCountdown();
    //getParticipantsStatus();
  }

  @override
  void dispose() {
    //resetWindowSize();
    _timer.cancel();
    _countdownTimer.cancel();
    super.dispose();
  }

  Future<void> createQrWindow() async {
    await windowManager.ensureInitialized();
    windowManager.setSize(Size(230, 250));
    print("-----------------QR WINDOW SIZE ${widget.xPos} ${widget.yPos}");
    windowManager.setPosition(Offset(double.parse(widget.xPos.toString()), double.parse(widget.yPos.toString())));
  }



  Future<void> hasMeetingEnded(int? meetingId) async {
    print("session/${widget.sessionId}/meetings/$meetingId/ ");
    final response = await http.get(
      Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/session/${widget.sessionId}/meetings/$meetingId/isCompleted"),
    );

    print(response);
    print("Meeting has ended: ${response.body}");
    if (response.body == "true") {
      await windowManager.ensureInitialized();
      windowManager.setSize(const Size(1200, 800));
      windowManager.center();
      //return context.go("/supervisor/${widget.supervisorEmail}/session/${widget.sessionId}");
      return context.go("/supervisor/${widget.supervisorEmail}");
    }
  }

  void addQrToMeeting() async {
    await http.put(
      Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/meeting/${widget.meetingId}/qr/$qrData"),
    );
  }



  void qrRefresher()  {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {

      await hasMeetingEnded(widget.meetingId);
      //getParticipantsStatus();
      setState(() {
        qrData = getRandomString(24);
        progress = 1.0; // Reset progress
        addQrToMeeting();
      });
    });
  }

  void startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        // Update progress every 100ms. Total duration is 10 seconds.
        progress = progress - 0.01;
        if (progress <= 0) {
          progress = 1.0; // Reset progress
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Center(
            child: QrImageView(
              data: qrData.toString(),
              version: QrVersions.auto,
              size: 600.0,
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 5.0,
              minWidth: 5.0,
              maxHeight: 500.0,
              maxWidth: 300.0,
            ),
          ),
          // LinearProgressIndicator to show countdown
          Padding(
            padding: const EdgeInsets.fromLTRB(128, 16, 128, 0),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
          ),
        ],
      ),
    );
  }
}
