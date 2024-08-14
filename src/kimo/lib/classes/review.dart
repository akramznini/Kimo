import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String docId;
  final String content;
  final int rating;
  final String reviewee;
  final String reviewer;
  final Timestamp timestamp;
  final String tripDocPath;

  Review({
    required this.docId,
    required this.content,
    required this.rating,
    required this.reviewee,
    required this.reviewer,
    required this.timestamp,
    required this.tripDocPath,
  });

  // Factory method to create a Review object from a Firestore document
  factory Review.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Review(
      docId: doc.id,
      content: data['content'],
      rating: (data['rating'] as num).toInt(),
      reviewee: data['reviewee'],
      reviewer: data['reviewer'],
      timestamp: data['timestamp'],
      tripDocPath: data['trip_doc_path'],
    );
  }

  // Method to convert a Review object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'rating': rating,
      'reviewee': reviewee,
      'reviewer': reviewer,
      'timestamp': timestamp,
      'trip_doc_path': tripDocPath,
    };
  }
}