import 'dart:convert';
import 'package:ams/models/sessionCard.dart';
import 'package:ams/supervisor/supervisorSessionScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class SupervisorScreen extends StatefulWidget {
  final String supervisorEmail;
  const SupervisorScreen({super.key, required this.supervisorEmail});

  @override
  State<SupervisorScreen> createState() => _SupervisorScreenState();
}

class _SupervisorScreenState extends State<SupervisorScreen> {
  Map<String, int> sessions = {};
  String? selectedSession;

  void fetchSessions() async {
    final response = await http.get(
      Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/supervisor/getAllSessions/${widget.supervisorEmail}"),
    );

    final data = jsonDecode(response.body);
    Map<String, int> tempSessions = {};

    for (var session in data) {
      tempSessions[session["name"]] = session["id"]; // Assuming 'id' is the correct key
    }

    setState(() {
      sessions = tempSessions;
    });
  }


  @override
  void initState() {
    super.initState();
    fetchSessions();
  }

  @override
  Widget build(BuildContext context) {
    var sessionNames = sessions.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Center(child: Text("Supervisor Dashboard"))),
      body: Row(
        children: [
          // Navigation Drawer
          Drawer(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                String sessionName = sessionNames[index];
                return ListTile(
                  leading: Icon(Icons.expand_circle_down_rounded, color: Colors.blue),
                  title: Text(sessionName, style: TextStyle(fontSize: 18)),
                  onTap: () {
                    setState(() {
                      selectedSession = sessionName;
                    });
                  },
                );
              },
            ),
          ),
          // Existing content
          Expanded(
            child: selectedSession == null
                ? Center(child: Text('Select a session from the drawer'))
                : SupervisorSessionScreen(
              key: ValueKey(selectedSession),
              sessionId: sessions[selectedSession]!,
              supervisorEmail: widget.supervisorEmail,
            ),
          ),
        ],
      ),
    );
  }
}



