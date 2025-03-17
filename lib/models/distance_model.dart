import 'package:geolocator/geolocator.dart';

class DistanceModel {
  final double latitude;
  final double longitude;

  DistanceModel({
    required this.latitude,
    required this.longitude,
  });

  // Method to calculate distance between two locations in kilometers
  double calculateDistance(DistanceModel otherLocation) {
    double distanceInMeters = Geolocator.distanceBetween(
      latitude,
      longitude,
      otherLocation.latitude,
      otherLocation.longitude,
    );
    return distanceInMeters / 1000; // Convert meters to km
  }
}
