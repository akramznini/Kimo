import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kimo/classes/listing_owner.dart';
import 'package:kimo/classes/trip.dart';
import 'package:kimo/utils/theme_values.dart';
import 'package:kimo/widgets/widgets.dart';

class ConversationPage extends StatefulWidget {
  const ConversationPage({
    super.key,
    required this.chatDocId,
    required this.trip,
    required this.recipient,
    required this.user
  });
  final Trip trip;
  final ListingOwner recipient;
  final String chatDocId;
  final User user;
  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  late final Stream<QuerySnapshot> _conversationStream;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
    _conversationStream = FirebaseFirestore.instance.collection("chat_rooms").doc(widget.chatDocId).collection("messages").orderBy("timestamp", descending: true).snapshots();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(stream: _conversationStream, builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CenteredCircularProgressIndicator();
        }
        
        else if (snapshot.hasError) {
          print(snapshot.error.toString());
          return Text("error: ${snapshot.error}");
        }
        
        else {
          List<Widget> messagesWidgets = [];
          for (var doc in snapshot.data!.docs) {
            var docData = doc.data() as Map<String, dynamic>;
            bool isUser = docData["author_uid"] == widget.user.uid;
            messagesWidgets.add(Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  MessageContainer(content: docData["content"], color: isUser ? onPrimary : greySelected, textColor: isUser ? Colors.white : Colors.black),
                ],
              ),
            ));
          }
          var controller = TextEditingController();
          return Column(
            children: [
              ConversationHeader(recipient: widget.recipient, trip: widget.trip),
              Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ListView(
                  reverse: true,
                  children: messagesWidgets,),
              )),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: MessageInput(onSendClick: () async {
                  await FirebaseFirestore.instance.collection("chat_rooms").doc(widget.chatDocId).collection("messages").add({"content": controller.text, "author_uid": widget.user.uid, "timestamp": Timestamp.now()});
                  controller.clear();
                }, controller: controller),
              )
            ],
          );
        }
      }),
    );
  }
}