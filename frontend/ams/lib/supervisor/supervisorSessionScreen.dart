import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math' as math;
import 'package:ams/models/csvExporter.dart';
import 'package:ams/models/geofenceData.dart';
import 'package:ams/models/participantGradeField.dart';
import 'package:csv/csv.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;


import '../models/mapCircle.dart';
import '../models/participantDashboardStatus.dart';
import '../models/participantHistoryCard.dart';
import '../models/participantMeeting.dart'; // Import intl package


class SupervisorSessionScreen extends StatefulWidget {

  final int sessionId;
  final String supervisorEmail;
  const SupervisorSessionScreen({super.key, required this.sessionId, required this.supervisorEmail});


  @override
  State<SupervisorSessionScreen> createState() => _SupervisorSessionScreenState();
}

class _SupervisorSessionScreenState extends State<SupervisorSessionScreen> {

  bool displayQR = false;
  var participantNames = [];
  Map<String, int> participants = {};
  List<String> participantEmails = [];
  final TextEditingController studentEmailController = TextEditingController();
  final TextEditingController sessionDurationController = TextEditingController();
  final TextEditingController lateDurationController = TextEditingController();
  final TextEditingController absentDurationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  List<ParticipantDashboardStatus> participantStatuses = [];
  int selectedPositionIndex = 0;  // Default to first position
  List<bool> isSelected = [true, false, false, false, false];  // Corresponds to positions
  List<math.Point> qrWindowSizes = [math.Point(1480, 0), math.Point(0, 0), math.Point(1480, 700), math.Point(0, 700), math.Point(740, 350)];



  late int meetingId;
  List<List<dynamic>> meetingTimes = [];
  MapCircle circle = MapCircle(center: LatLng(0,0));


  void fetchEnrolledParticipants() async {
    final response = await http.get(
        //Uri.parse("http://10.0.2.2:5000/api/v1/session/${widget.sessionId}"),
        Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/session/${widget.sessionId}"),
    );

    final data = jsonDecode(response.body);
    Map<String, int> tempParticipants = {};
    List<String> tempEmails = [];

    var enrolledParticipants = data['enrolledParticipants'];
    if (enrolledParticipants != null) {
      for (var participant in enrolledParticipants) {
        String fullName = "${participant['firstName']} ${participant['lastName']}";
        tempParticipants[fullName] = participant['id'];
        tempEmails.add(participant['email']);
      }
    }
    setState(() {
      participants = tempParticipants;
      participantEmails = tempEmails;
    });

  }

  void addParticipantToSession(String email) async {
    final response = await http.put(
      //Uri.parse("http://10.0.2.2:5000/api/v1/session/${widget.sessionId}/participant/$email"),
      Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/session/${widget.sessionId}/participant/$email"),
    );
    fetchEnrolledParticipants();
  }

  void removeParticipantFromSession(int id) async {
    final response = await http.put(
      //Uri.parse("http://10.0.2.2:5000/api/v1/session/${widget.sessionId}/participant/$email"),
      Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/session/${widget.sessionId}/participant/remove/$id"),
    );
    fetchEnrolledParticipants();
  }

  Future<int> startMeeting() async {
    final response = await http.post(
      //Uri.parse("http://10.0.2.2:5000/api/v1/session/${widget.sessionId}/participant/$email"),
      Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/session/${widget.sessionId}/meetings/start"),
    );
    var data = jsonDecode(response.body);
    return data['id'];
  }

  void getPreviousMeetings() async {
    final response = await http.get(
      //Uri.parse("http://10.0.2.2:5000/api/v1/session/${widget.sessionId}"),
      Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/session/${widget.sessionId}/meetings"),
    );

    final data = jsonDecode(response.body);
    List<List<dynamic>> meetingDetailsTemp = [];

    for (var meeting in data) {
      DateTime startTime = DateTime.parse(meeting['startTime']);
      DateTime endTime = DateTime.parse(meeting['endTime']);
      int meetingId = meeting['id']; // Assuming the 'id' field is present in the response

      meetingDetailsTemp.add([startTime, endTime, meetingId]); // Also store the meeting ID

    }

    setState(() {
      meetingTimes = meetingDetailsTemp;
    });
  }

  Future<void> stopOngoingMeetings() async {
    final response = await http.post(
      Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/session/${widget.sessionId}/stopOngoingMeetings"),
    );
  }

  void getDescription() async {
    final response = await http.get(
      Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/session/${widget.sessionId}/description"),
    );

    descriptionController.text = response.body;
  }

  void getGeofenceData() async {
    final response = await http.get(
      Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/session/${widget.sessionId}/geofence"),
    );

    var data = jsonDecode(response.body);
    if (data['latitude'] == null) return;
    circle = MapCircle(center: LatLng(data['latitude'], data['longitude']), radius: data['radius']);
  }


  void saveSettings(String description, GeofenceData? geofenceData) {
    if (description != descriptionController.text) setDescription(description);
    if (geofenceData != null) setGeofence(geofenceData);
  }

  void setDescription(String description) async {
    final response = await http.put(
      Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/session/${widget.sessionId}/description"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "description": description,
      }),
    );
  }

  void setGeofence(GeofenceData geofenceData) async {
    final response = await http.put(
      Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/session/${widget.sessionId}/geofence"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "longitude": geofenceData.longitude,
        "latitude": geofenceData.latitude,
        "radius": geofenceData.radius,
      }),
    );
  }

  void setThresholds (int lateDuration, int absentDuration) async {
    final response = await http.put(
      Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/session/${widget.sessionId}/setDurations/$lateDuration/$absentDuration"),
    );
}

  void getThresholds () async {
    final response = await http.get(
      Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/session/${widget.sessionId}/getDurations"),
    );

    var data = jsonDecode(response.body);
    lateDurationController.text = data['lateThreshold'].toString();
    absentDurationController.text = data['absentThreshold'].toString();

  }

  Future<void> getParticipantsStatus(int meetingId) async {
    final response = await http.get(
      Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/session/${widget.sessionId}/meeting/${meetingId}/getParticipantsStatus"),
    );
    final data = jsonDecode(response.body);

    List<ParticipantDashboardStatus> statusTemp = [];

    for (var participant in data) {
      ParticipantMeetingStatus status = ParticipantMeetingStatus.fromString(participant['status']);
      var newStatus = ParticipantDashboardStatus(participant['name'], status);
      statusTemp.add(newStatus);
    }

    participantStatuses = statusTemp;
  }


  @override
  void initState() {
    super.initState();
    print("RECEIVED: ${widget.sessionId} ${widget.supervisorEmail}");
    fetchEnrolledParticipants();
    loadMeetingsHistory();
    getDescription();
    getGeofenceData();
    getThresholds();
  }

  // void exportCsv() async {
  //   var exporter = CsvExporter(widget.sessionId);
  // }

  void loadMeetingsHistory() async {
    await stopOngoingMeetings();
    getPreviousMeetings();
  }


  void _handleTap(LatLng latlng, double prevRadius) {
    setState(() {
      circle = MapCircle(center: latlng, radius: prevRadius);
    });
  }

  double _currentSliderValue = 60;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(title: const Center(child: Text("Supervisor Dashboard"))),
        body: Center(

          child: SingleChildScrollView(
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 5.0,
                    minWidth: 5.0,
                    maxHeight: 500.0,
                    maxWidth: 500.0,
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
                        shrinkWrap: true,
                        itemCount: participants.length,
                        itemBuilder: (context, index) {
                          var entry = participants.entries.elementAt(index);
                          String participantName = entry.key;
                          int participantId = entry.value;
                          return ListTile(
                            leading: IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text("$participantName:", style: const TextStyle(fontSize: 30, fontWeight:  FontWeight.bold),),
            
                                            ParticipantGradeField(sessionId:  widget.sessionId, participantEmail: participantEmails[index]),
            
                                            Container(
                                                width: 600,
                                                height: 300,
                                                child: ParticipantHistoryCard(sessionId:  widget.sessionId, participantEmail: participantEmails[index])),
                                          ],
                                        ),
            
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();  // This will close the dialog
                                            },
                                            child: const Text('OK', style: TextStyle(color: Colors.blue)),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(Icons.account_box)
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                removeParticipantFromSession(participantId);
                              },
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                            ),
                            title: Text(participantName),
                          );
            
                        },
                      ),
                    ),
                  ),
                ),
            
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 5.0,
                    minWidth: 5.0,
                    maxHeight: 300.0,
                    maxWidth: 300.0,
                  ),
                  child: TextField(
                    controller: studentEmailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter participant email',
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        addParticipantToSession(studentEmailController.text);
                      }, child: const Text("Add Participant"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['csv'],
                        );

                        if (result != null) {
                          PlatformFile file = result.files.first;

                          final inputFile = File(file.path!);
                          String contents = await inputFile.readAsString();
                          List<List<dynamic>> listData = const CsvToListConverter().convert(contents);
                          for (var list in listData){
                            for (var email in list) {
                              addParticipantToSession(email);
                            }
                          }
                        } else {
                          print("No file selected");
                        }

                      }, child: const Text("Import CSV"),
                    ),
                    ElevatedButton(
                      onPressed: () {

                      }, child: const Text("Export CSV"),
                    ),
                  ],
                ),
            
                const SizedBox(height: 20),
            
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 5.0,
                    minWidth: 5.0,
                    maxHeight: 500.0,
                    maxWidth: 600.0,
                  ),
                  child: Card(
                    elevation: 4.0,
                    margin: EdgeInsets.all(8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Rounded corners
                    ),
                    child: SizedBox(
                      height: 200,
                      width: 600,
                      child: ListView.builder(
                        itemCount: meetingTimes.length,
                        itemBuilder: (context, index) {
                          DateTime startTime = meetingTimes[index][0];
                          DateTime endTime = meetingTimes[index][1];
            
                          DateTime adjustedStartTime = startTime.add(Duration(hours: 4)); // Adjust for timezone
                          DateTime adjustedEndTime = endTime.add(Duration(hours: 4)); // Adjust for timezone
            
                          String formattedDate = DateFormat('yyyy-MM-dd').format(adjustedStartTime);
                          String formattedStartTime = DateFormat('HH:mm:ss').format(adjustedStartTime);
                          String formattedEndTime = DateFormat('HH:mm:ss').format(adjustedEndTime);
            
                          // Alternate background color
                          Color backgroundColor = index % 2 == 0 ? Colors.white : Colors.grey[200]!;

                          return Container(
                            color: backgroundColor,
                            child: ListTile(
                              leading: IconButton(
                                onPressed: () async {
                                  int selectedMeetingId = meetingTimes[index][2]; // Retrieve the stored meeting ID
                                  await getParticipantsStatus(selectedMeetingId);
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 600,
                                              height: 300,
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
                                          ],
                                        ),

                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();  // This will close the dialog
                                            },
                                            child: const Text('OK', style: TextStyle(color: Colors.blue)),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                  icon: Icon(Icons.class_rounded),
                              ),
                              title: Text("Date: $formattedDate, Start time: $formattedStartTime, End time: $formattedEndTime"),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),


                SizedBox(
                  width: 200,
                  height: 120,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
                    child: ElevatedButton(
                      onPressed: () async {
                        meetingId = await startMeeting();

                        final window = await DesktopMultiWindow.createWindow(jsonEncode({
                          'args1': widget.sessionId,
                          'args2': meetingId,
                        }));
                        window
                          ..setFrame(const Offset(0, 0) & const ui.Size(1280, 720))
                          ..center()
                          ..setTitle('Meeting Dashboard')
                          ..show();

                        await Future.delayed(Duration(seconds: 1));

                        return context.go("/supervisor/${widget.supervisorEmail}/qr/${widget.sessionId}/$meetingId/${qrWindowSizes[selectedPositionIndex].x}/${qrWindowSizes[selectedPositionIndex].y}");
                      }, child: const Text("Start Attendance Check"),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 5.0,
                          minWidth: 5.0,
                          maxHeight: 300.0,
                          maxWidth: 150.0,
                        ),
                        child: TextField(
                          controller: lateDurationController,
                          keyboardType: TextInputType.number, // Ensures only numbers can be entered
                          decoration: const InputDecoration(
                            labelText: "Late After",
                            border: OutlineInputBorder(),
                            suffixText: "minutes",
                          ),
                        ),
                      ),

                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 5.0,
                          minWidth: 5.0,
                          maxHeight: 300.0,
                          maxWidth: 150.0,
                        ),
                        child: TextField(
                          controller: absentDurationController,
                          keyboardType: TextInputType.number, // Ensures only numbers can be entered
                          decoration: const InputDecoration(
                            labelText: "Absent After",
                            border: OutlineInputBorder(),
                            suffixText: "minutes",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: SizedBox(
                    width: 800,
                    height: 400,
                    child:  FlutterMap(
                      options: MapOptions(
                        center: LatLng(40.396822, 49.849458),
                        zoom: 16.0,
                        onTap: (_, latlng) => _handleTap(latlng, circle.radius),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                        ),
                        CircleLayer(
                          circles: [
                            CircleMarker(
                              point: circle.center,
                              color: circle.color.withOpacity(0.7),
                              borderColor: Colors.pink,
                              borderStrokeWidth: 2,
                              useRadiusInMeter: true,
                              radius: circle.radius,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Slider(
                  value: circle.radius,
                  min: 10,
                  max: 300,
                  divisions: 29,
                  label: circle.radius.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      circle = MapCircle(center: circle.center, radius: value, color: circle.color);});
                  },
                ),

                SizedBox(
                  width: 600,
                  child: TextField(
                    controller: descriptionController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Session description",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),


                // Add this within the build method, right above your existing Save button
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("QR Code Position", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    ToggleButtons(
                      borderColor: Colors.deepPurple,
                      fillColor: Colors.deepPurpleAccent,
                      borderWidth: 2,
                      selectedBorderColor: Colors.deepPurple,
                      selectedColor: Colors.white,
                      borderRadius: BorderRadius.circular(0),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Top Right'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Top Left'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Bottom Right'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Bottom Left'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Center'),
                        ),
                      ],
                      onPressed: (int index) {
                        setState(() {
                          for (int buttonIndex = 0; buttonIndex < isSelected.length; buttonIndex++) {
                            if (buttonIndex == index) {
                              isSelected[buttonIndex] = true;
                            } else {
                              isSelected[buttonIndex] = false;
                            }
                          }
                          selectedPositionIndex = index; // Update the position index
                        });
                      },
                      isSelected: isSelected,
                    ),
                  ],
                ),


                ElevatedButton(
                    onPressed: () {
                      setDescription(descriptionController.text);

                      GeofenceData data = GeofenceData(longitude: circle.center.longitude,
                          latitude: circle.center.latitude, radius: circle.radius);

                      setGeofence(data);
                      setThresholds(int.parse(lateDurationController.text), int.parse(absentDurationController.text));
                    },
                    child: const Text("Save")),
              ],
            ),
          ),
        ),
      );
  }
}
