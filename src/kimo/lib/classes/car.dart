import 'package:cloud_firestore/cloud_firestore.dart';

class Car {
  String brand;
  int dailyRate;
  String fuel;
  GeoPoint location;
  String model;
  int nbReviews;
  int nbSeats;
  String ownerDocId;
  List<String> pictures;
  double rating;
  String transmission;
  int year;
  final Address address;
  Car({
    required this.address,
    required this.brand,
    required this.dailyRate,
    required this.fuel,
    required this.location,
    required this.model,
    required this.nbReviews,
    required this.nbSeats,
    required this.ownerDocId,
    required this.pictures,
    required this.rating,
    required this.transmission,
    required this.year,
  });

  // Factory method to create a Car instance from Firestore document
  factory Car.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Car(
      address: Address.fromMap(data['address']),
      brand: data['brand'] ?? '',
      dailyRate: data['daily_rate'] ?? 0,
      fuel: data['fuel'] ?? '',
      location: data['location'] ?? GeoPoint(0, 0),
      model: data['model'] ?? '',
      nbReviews: data['nb_reviews'] ?? 0,
      nbSeats: data['nb_seats'] ?? 0,
      ownerDocId: data['owner_doc_id'] ?? '',
      pictures: List<String>.from(data['pictures'] ?? []),
      rating: data['rating'] ?? 0.0,
      transmission: data['transmission'] ?? '',
      year: data['year'] ?? 0,
    );
  }

  // Method to convert Car instance to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'address': address.toMap(),
      'brand': brand,
      'daily_rate': dailyRate,
      'fuel': fuel,
      'location': location,
      'model': model,
      'nb_reviews': nbReviews,
      'nb_seats': nbSeats,
      'owner_doc_id': ownerDocId,
      'pictures': pictures,
      'rating': rating,
      'transmission': transmission,
      'year': year,
    };
  }
  
}
class Address {
  final String city;
  final String postalCode;
  final String province;
  final String streetNumber;

  Address({
    required this.city,
    required this.postalCode,
    required this.province,
    required this.streetNumber,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      city: map['city'],
      postalCode: map['postal_code'],
      province: map['province'],
      streetNumber: map['street_number'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'city': city,
      'postal_code': postalCode,
      'province': province,
      'street_number': streetNumber,
    };
  }
}