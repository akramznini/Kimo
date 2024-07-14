import 'package:cloud_firestore/cloud_firestore.dart';

class ListingOwner {
  final String firstName;
  final String lastName;
  final int nbReviews;
  final int nbTrips;
  final String profilePictureUrl;
  final double rating;

  ListingOwner({
    required this.firstName,
    required this.lastName,
    required this.nbReviews,
    required this.profilePictureUrl,
    required this.rating,
    required this.nbTrips
  });

  // Factory constructor to create an instance from a Firestore document
  factory ListingOwner.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return ListingOwner(
      firstName: data['first_name'] as String,
      lastName: data['last_name'] as String,
      nbReviews: data['nb_reviews'] as int,
      nbTrips: data['nb_trips'] as int,
      profilePictureUrl: data['profile_picture_url'] as String,
      rating: (data['rating'] as num).toDouble(),
    );
  }
}