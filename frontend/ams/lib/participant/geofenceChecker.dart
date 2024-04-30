import 'package:geolocator/geolocator.dart';

class GeofenceChecker {
  final double centerLatitude;
  final double centerLongitude;
  final double radius;

  GeofenceChecker({required this.centerLatitude, required this.centerLongitude, required this.radius});

  Future<bool> isPositionInside() async {
    Position currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    double distanceInMeters = Geolocator.distanceBetween(
        centerLatitude,
        centerLongitude,
        currentPosition.latitude,
        currentPosition.longitude
    );

    return distanceInMeters <= radius;
  }
}
