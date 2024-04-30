import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class GeofenceTest extends StatefulWidget {
  final int sessionId;
  final String participantEmail;
  final String sessionName;
  final int meetingId;
  const GeofenceTest({Key? key, required this.sessionId, required this.participantEmail,
  required this.sessionName, required this.meetingId}) : super(key: key);

  @override
  State<GeofenceTest> createState() => _GeofenceTestState();
}

class _GeofenceTestState extends State<GeofenceTest> {
  bool? isInside;
  Position? currentPosition;
  LatLng? geofenceCenter;
  double? geofenceRadius;
  bool isLoading = true;  // Added to manage loading state

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    await determinePosition();  // Ensure current position is fetched first
    await fetchGeofenceData();  // Then fetch geofence data
    checkIfInside();            // Finally check if inside
  }

  Future<void> fetchGeofenceData() async {
    final response = await http.get(
      Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/session/${widget.sessionId}/geofence"),
    );
    var data = jsonDecode(response.body);
    if (data != null) {
      geofenceCenter = LatLng(data['latitude'], data['longitude']);
      geofenceRadius = data['radius'].toDouble();
    }
    setState(() {
      isLoading = false;  // Update loading state
    });
  }

  Future<void> determinePosition() async {
    currentPosition = await Geolocator.getCurrentPosition();
  }

  Future<void> checkIfInside() async {
    if (currentPosition == null || geofenceCenter == null || geofenceRadius == null) {
      print("Geofence data is not complete.");
      return;
    }
    double distance = Geolocator.distanceBetween(
      currentPosition!.latitude,
      currentPosition!.longitude,
      geofenceCenter!.latitude,
      geofenceCenter!.longitude,
    );
    isInside = distance <= geofenceRadius!;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? const Center(child: CircularProgressIndicator()) : buildMap(),
      bottomSheet: isInside == null
          ? null
          : Container(
        color: isInside! ? Colors.green : Colors.red,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isInside! ? "You are in the correct location!" : "You are not in the correct location",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            if (isInside!)
              ElevatedButton(
                onPressed: () {
                  return context.go("/participant/${widget.participantEmail}/session/${widget.sessionId}/${widget.sessionName}/faceIdentification/${widget.meetingId}");
                },
                child: const Text("Next"),
              )
          ],
        ),
      ),
    );
  }

  Widget buildMap() {
    return FlutterMap(
      options: MapOptions(
        center: geofenceCenter,  // No longer using a default center
        zoom: 16.0,
      ),
      children: [
      TileLayer(
      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      subdomains: ['a', 'b', 'c'],
    ),
    if (geofenceCenter != null && geofenceRadius != null)
        CircleLayer(
        circles: [
        CircleMarker(
        point: geofenceCenter!,
        color: Colors.green.withOpacity(0.3),
        borderColor: Colors.green,
        borderStrokeWidth: 3,
        radius: geofenceRadius!,
        useRadiusInMeter: true
        ),
      ],
    ),
        if (currentPosition != null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: LatLng(currentPosition!.latitude, currentPosition!.longitude),
                color: Colors.red.withOpacity(0.7),
                radius: 10, // This specifies the radius in meters for the user's location marker
                useRadiusInMeter: true,
              ),
            ],
          ),
      ],
    );
  }
}
