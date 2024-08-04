import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String guestUid;
  final int guestUnseenMessages;
  final String hostUid;
  final int hostUnseenMessages;
  final String tripDocPath;

  // Constructor
  ChatRoom({
    required this.guestUid,
    required this.guestUnseenMessages,
    required this.hostUid,
    required this.hostUnseenMessages,
    required this.tripDocPath,
  });

  // Factory constructor to create a ChatRoom object from a Firestore document
  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    return ChatRoom(
      guestUid: doc['guest_uid'] as String,
      guestUnseenMessages: doc['guest_unseen_messages'] as int,
      hostUid: doc['host_uid'] as String,
      hostUnseenMessages: doc['host_unseen_messages'] as int,
      tripDocPath: doc['trip_doc_path'] as String,
    );
  }

  // Method to convert a ChatRoom object to a map (useful for updating Firestore)
  Map<String, dynamic> toMap() {
    return {
      'guest_uid': guestUid,
      'guest_unseen_messages': guestUnseenMessages,
      'host_uid': hostUid,
      'host_unseen_messages': hostUnseenMessages,
      'trip_doc_path': tripDocPath,
    };
  }
}