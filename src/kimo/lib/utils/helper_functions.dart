import 'dart:math';

import 'package:url_launcher/url_launcher.dart';

Future<void> openMap(double latitude, double longitude) async {
  final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
  final String appleMapsUrl = 'https://maps.apple.com/?q=$latitude,$longitude';

  if (await canLaunch(googleMapsUrl)) {
    await launch(googleMapsUrl);
  } else if (await canLaunch(appleMapsUrl)) {
    await launch(appleMapsUrl);
  } else {
    throw 'Could not launch the map.';
  }
}


class LatLngBounds {
  final double lowLong;
  final double highLong;
  final double lowLat;
  final double highLat;

  LatLngBounds(this.lowLong, this.highLong, this.lowLat, this.highLat);

  @override
  String toString() {
    return 'LatLngBounds{lowLang: $lowLong, highLang: $highLong, lowLat: $lowLat, highLat: $highLat}';
  }
}

LatLngBounds calculateBounds(double latitude, double longitude, double distanceInKm) {
  double kmPerLatDegree = 1000;
  double kmPerLongDegree = kmPerLatDegree*cos(latitude);
  
  // Latitude bounds
  double lowLat = latitude - distanceInKm/kmPerLatDegree;
  double highLat = latitude + distanceInKm/kmPerLatDegree;

  // Longitude bounds
  double lowLong = longitude - distanceInKm/kmPerLongDegree;
  double highLong = longitude + distanceInKm/kmPerLongDegree;
  

  return LatLngBounds(lowLong, highLong, lowLat, highLat);
}

String dateTimeToString(DateTime dateTime){
  List<String> weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  List<String> months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  print(dateTime.weekday);
  // return "${weekdays[dateTime.weekday - 1]}, ${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.hour >= 13 ? "${dateTime.hour - 12}:${dateTime.minute} PM" : "${dateTime.hour}:${dateTime.minute} AM"}";
  return "${weekdays[dateTime.weekday - 1]}, ${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}";
}