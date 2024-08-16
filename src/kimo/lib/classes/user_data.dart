import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String uid;
  DateTime dateOfBirth;
  String email;
  String firstName;
  String lastName;
  int nbReviews;
  int nbTrips;
  String phoneNumber;
  String profilePictureUrl;
  double rating;
  List<dynamic> wishlist;
  final String docId;
  UserData({
    required this.uid,
    required this.dateOfBirth,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.nbReviews,
    required this.nbTrips,
    required this.phoneNumber,
    required this.profilePictureUrl,
    required this.rating,
    required this.wishlist,
    required this.docId
  });

  // Factory method to create a UserInfo object from a Firestore document snapshot
  factory UserData.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserData(
      docId: doc.id,
      uid: data['UID'] as String,
      dateOfBirth: (data['date_of_birth'] as Timestamp).toDate(),
      email: data['email'] as String,
      firstName: data['first_name'] as String,
      lastName: data['last_name'] as String,
      nbReviews: data['nb_reviews'] as int,
      nbTrips: data['nb_trips'] as int,
      phoneNumber: data['phone_number'] as String,
      profilePictureUrl: data['profile_picture_url'] as String,
      rating: (data['rating'] as num).toDouble(),
      wishlist: data['wishlist'] as List<dynamic>,
    );
  }

  // Method to convert a UserInfo object back to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'UID': uid,
      'date_of_birth': Timestamp.fromDate(dateOfBirth),
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'nb_reviews': nbReviews,
      'nb_trips': nbTrips,
      'phone_number': phoneNumber,
      'profile_picture_url': profilePictureUrl,
      'rating': rating,
      'wishlist': wishlist,
    };
  }
}