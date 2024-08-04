import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String authorUid;
  final String content;
  final Timestamp timestamp; // Use Firestore's Timestamp type

  // Constructor
  Message({
    required this.authorUid,
    required this.content,
    required this.timestamp,
  });

  // Factory constructor to create a Message object from a Firestore document
  factory Message.fromFirestore(DocumentSnapshot doc) {
    return Message(
      authorUid: doc['author_uid'] as String,
      content: doc['content'] as String,
      timestamp: doc['timestamp'] as Timestamp,
    );
  }

  // Method to convert a Message object to a map (useful for updating Firestore)
  Map<String, dynamic> toMap() {
    return {
      'author_uid': authorUid,
      'content': content,
      'timestamp': timestamp,
    };
  }

  // Convert Firestore Timestamp to Dart DateTime
  DateTime get timestampDateTime => timestamp.toDate();
}