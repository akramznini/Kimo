import 'package:cloud_firestore/cloud_firestore.dart';

class City {
  String country;
  String name;
  String province;

  City({
    required this.country,
    required this.name,
    required this.province,
  });

  // Method to create a City instance from a Firestore document
  factory City.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return City(
      country: data['country'] ?? '',
      name: data['name'] ?? '',
      province: data['province'] ?? '',
    );
  }

  // Method to convert a City instance into a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'country': country,
      'name': name,
      'province': province,
    };
  }
}