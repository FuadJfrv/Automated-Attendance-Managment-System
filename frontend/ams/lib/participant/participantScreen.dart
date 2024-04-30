import 'dart:convert';
import 'dart:ffi';
import 'dart:math' as math;
import 'package:ams/models/sessionCard.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:developer';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class ParticipantScreen extends StatefulWidget {
  final String participantEmail;
  const ParticipantScreen({super.key, required this.participantEmail});

  @override
  State<ParticipantScreen> createState() => _ParticipantScreenState();
}

class _ParticipantScreenState extends State<ParticipantScreen> {
  // Change sessions to Map<String, int> to match your data structure
  Map<String, int> sessions = {};

  late int id;
  Map<int, bool> activeMeetings = {};

  void fetchSessions() async {
    final response = await http.get(
      Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/participant/${widget.participantEmail}/getAllSessions"),
    );

    final data = jsonDecode(response.body);
    Map<String, int> tempSessions = {};
    Map<int, bool> activeStatuses = {}; // Map to hold active status

    for (var session in data) {
      tempSessions[session["name"]] = session["id"];
      bool isActive = await hasActiveMeeting(session["id"]);
      activeStatuses[session["id"]] = isActive;
    }

    setState(() {
      sessions = tempSessions;
      activeMeetings = activeStatuses; // Store in a state variable
    });
  }



  Future<void> uploadProfilePicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      final bytes = await image.readAsBytes();
      final encodedImage = base64Encode(bytes);

      var url = Uri.parse('https://lxmz2mxgj8.execute-api.eu-west-2.amazonaws.com/beta/store-face');
      var headers = {'Content-Type': 'application/json'};
      var body = jsonEncode({
        'imageData': encodedImage,
        'fileName': '$id.jpg',
        'fullName': '$id'
      });

      var response = await http.post(url, headers: headers, body: body);

      print(response.body);
      if (response.statusCode == 200) {
        print('Image uploaded successfully');
      } else {
        print('Failed to upload image');
      }
    }
  }

  Future<int> getParticipantId(String email) async {
    final response = await http.get(
      //Uri.parse("http://10.0.2.2:5000/api/v1/participant/345@gmail.com/getAllSessions"),
      Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/participant/${widget.participantEmail}/getId"),
    );
    print("ID: ${response.body}");
    return int.parse(response.body);
  }

  Future<bool> hasActiveMeeting(int sessionId) async {
    final response = await http.get(
      //Uri.parse("http://10.0.2.2:5000/api/v1/participant/345@gmail.com/getAllSessions"),
      Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/session/$sessionId/meetings/active"),
    );
    if (response.body == "NO ACTIVE MEETINGS") {
      return false;
    } else {
      return true;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSessions();
    setPrefs();
    //sendImageTest();
  }

  void sendImageTest() async {
    uploadProfilePicture();
  }

  Future<void> setPrefs() async {
    Position currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    print(currentPosition);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("participantEmail", widget.participantEmail);
    id = await getParticipantId(widget.participantEmail);
    prefs.setInt("participantId", id);
  }

  @override
  Widget build(BuildContext context) {
    // Convert sessions Map to a list of its keys for indexing
    var sessionNames = sessions.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Center(child: Text("Participant Dashboard"))),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                String sessionName = sessionNames[index];
                int sessionId = sessions[sessionName]!;

                return FutureBuilder<bool>(
                  future: hasActiveMeeting(sessionId),
                  builder: (context, snapshot) {
                    bool isActive = snapshot.hasData && snapshot.data!;
                    return InkWell(
                      onTap: () {
                        context.go("/participant/${widget.participantEmail}/session/$sessionId/$sessionName");
                      },
                      child: SessionCard(sessionName: sessionName, active: isActive),
                    );
                  },
                );
              },
            ),

          ),

          ElevatedButton(
              onPressed: () {
            uploadProfilePicture();
          },
              child: Text("Set profile picture")),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
                onPressed: () {
                  fetchSessions();
                },
                backgroundColor: Colors.deepPurple,
                child: const Icon(Icons.refresh_rounded),
            ),
          )
        ],
      ),
    );
  }
}

