import 'dart:math';
import 'package:geolocator/geolocator.dart';

class LatLngBounds {
  final double lowLang;
  final double highLang;
  final double lowLat;
  final double highLat;

  LatLngBounds(this.lowLang, this.highLang, this.lowLat, this.highLat);

  @override
  String toString() {
    return 'LatLngBounds{lowLang: $lowLang, highLang: $highLang, lowLat: $lowLat, highLat: $highLat}';
  }
}

LatLngBounds calculateBounds(double latitude, double longitude, double distanceInKm) {
  // Radius of the Earth in km
  const double R = 6371.0;

  // Convert distance from km to radians
  double distanceRadians = distanceInKm / R;

  // Convert latitude and longitude from degrees to radians
  double latRadians = latitude * pi / 180.0;
  double lonRadians = longitude * pi / 180.0;

  // Calculate bounding box coordinates
  double lowLang = longitude - (distanceRadians / cos(latRadians));
  double highLang = longitude + (distanceRadians / cos(latRadians));
  double lowLat = latitude - distanceRadians;
  double highLat = latitude + distanceRadians;

  return LatLngBounds(lowLang, highLang, lowLat, highLat);
}

