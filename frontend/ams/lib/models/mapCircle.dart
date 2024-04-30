import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class MapCircle {
  final LatLng center;
  final double radius;
  final Color color;

  MapCircle({required this.center, this.radius = 60, this.color = Colors.blue});
}
