import 'package:cloud_firestore/cloud_firestore.dart';

class Listing {
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
  String picturePath;
  String pictureUrl;
  // Constructor
  Listing({
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
    required this.picturePath,
    this.pictureUrl = ""
  });

  // Factory constructor to create a Car object from a Firestore DocumentSnapshot
  factory Listing.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  
    return Listing(
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
      picturePath: data['picture_path']
    );
  }
}