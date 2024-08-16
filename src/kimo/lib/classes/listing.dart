import 'package:cloud_firestore/cloud_firestore.dart';

class Listing {
  String docId;
  String brand;
  String model;
  String carId; // This can be used to store the Firestore document ID
  int dailyRate;
  Timestamp endDate;
  int nbReviews;
  int nbSeats;
  double positionLatitude;
  double positionLongitude;
  double rating;
  Timestamp startDate;
  String pictureUrl;
  String city;
  String fuel;
  String transmission;
  // Constructor
  Listing({
    required this.docId,
    required this.brand,
    required this.model,
    required this.carId,
    required this.dailyRate,
    required this.endDate,
    required this.nbReviews,
    required this.nbSeats,
    required this.positionLatitude,
    required this.positionLongitude,
    required this.rating,
    required this.startDate,
    required this.pictureUrl,
    required this.city,
    required this.fuel,
    required this.transmission
  });

  // Factory constructor to create a Car object from a Firestore DocumentSnapshot
  factory Listing.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  
    return Listing(
      docId: doc.id ?? '',
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      carId: data['car'],
      dailyRate: data['daily_rate'] ?? 0,
      endDate: data['end_date'] ?? Timestamp.now(),
      nbReviews: data['nb_reviews'] ?? 0,
      nbSeats: data['nb_seats'] ?? 0,
      positionLatitude: data['position_latitude'] ?? 0.0,
      positionLongitude: data['position_longitude'] ?? 0.0,
      rating: (data['rating'] is num ? data['rating'].toDouble() : 0.0),
      startDate: data['start_date'] ?? Timestamp.now(),
      pictureUrl: data['picture_url'],
      city: data['city'],
      fuel: data['fuel'],
      transmission: data['transmission']
    );
  }
  factory Listing.fromMap(Map<String, dynamic> data) {
  
    return Listing(
      docId: data['docId'] ?? '',
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      carId: data['car'],
      dailyRate: data['daily_rate'] ?? 0,
      endDate: data['end_date'] ?? Timestamp.now(),
      nbReviews: data['nb_reviews'] ?? 0,
      nbSeats: data['nb_seats'] ?? 0,
      positionLatitude: data['position_latitude'] ?? 0.0,
      positionLongitude: data['position_longitude'] ?? 0.0,
      rating: (data['rating'] is num ? data['rating'].toDouble() : 0.0),
      startDate: data['start_date'] ?? Timestamp.now(),
      pictureUrl: data['picture_url'],
      city: data['city'],
      fuel: data['fuel'],
      transmission: data['transmission']
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'model': model,
      'car': carId,
      'daily_rate': dailyRate,
      'end_date': endDate,
      'nb_reviews': nbReviews,
      'nb_seats': nbSeats,
      'position_latitude': positionLatitude,
      'position_longitude': positionLongitude,
      'rating': rating,
      'start_date': startDate,
      'picture_url': pictureUrl,
      'city': city,
      'fuel': fuel,
      'transmission': transmission
    };}
  Map<String, dynamic> toMapWithDocId() {
    return {
      'docId': docId,
      'brand': brand,
      'model': model,
      'car': carId,
      'daily_rate': dailyRate,
      'end_date': endDate,
      'nb_reviews': nbReviews,
      'nb_seats': nbSeats,
      'position_latitude': positionLatitude,
      'position_longitude': positionLongitude,
      'rating': rating,
      'start_date': startDate,
      'picture_url': pictureUrl,
      'city': city,
      'fuel': fuel,
      'transmission': transmission
    };}
}