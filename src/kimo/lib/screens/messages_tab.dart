import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kimo/classes/chat_room.dart';

import 'package:kimo/classes/listing_owner.dart';
import 'package:kimo/classes/message.dart';
import 'package:kimo/classes/trip.dart';
import 'package:kimo/screens/conversation_page.dart';
import 'package:kimo/utils/theme_values.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kimo/widgets/widgets.dart';

class MessagesTab extends StatefulWidget {
  const MessagesTab({
    super.key,
    required this.user
  });
  
  final User ?user;

  @override
  State<MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  late final Stream<QuerySnapshot> _conversationsStream;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _conversationsStream = FirebaseFirestore.instance.collection("chat_rooms").where("guest_uid", isEqualTo: widget.user!.uid).snapshots();
  }

  Future<List<Widget>> fetchChatRoomsData(List<QueryDocumentSnapshot> docs) async {
    List<Widget> chatRooms = [];
    try {
      for (DocumentSnapshot document in docs) {
                        ChatRoom chatRoom = ChatRoom.fromFirestore(document);
                        print("line1");
                        var recipientDoc = (await FirebaseFirestore.instance.collection("users").where("UID", isEqualTo: chatRoom.hostUid).get()).docs.first;
                        print("line2");
                        var recipient = ListingOwner.fromFirestore(recipientDoc);
                        print("line3");
                        print("trip docpath: ${chatRoom.tripDocPath}");
                        var tripDoc = (await FirebaseFirestore.instance.doc(chatRoom.tripDocPath).get());
                        print("line4");
                        print(tripDoc.data());
                        var trip = Trip.fromFirestore(tripDoc);
                        print("line5");
                        var message = Message.fromFirestore((await FirebaseFirestore.instance.collection("chat_rooms").doc(document.id).collection("messages").orderBy("timestamp", descending: true).limit(1).get()).docs.first);
                        print("line6");
                        chatRooms.add(ConversationPreview(onTap:(){
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) {return ConversationPage(chatDocId: document.id, recipient: recipient, trip: trip, user: widget.user!,);})).then((value) async {
                            await FirebaseFirestore.instance.collection("chat_rooms").doc(document.id).update({'guest_unseen_messages': 0});
                          });
                        }, recipient: recipient.firstName, carName: "${trip.carBrand} ${trip.carModel}", lastMessage: message.content, recipientProfilePictureUrl: recipient.profilePictureUrl, nbUnseenMessages: chatRoom.guestUnseenMessages));
                        print("line7");
                        chatRooms.add(Divider(color: Color.fromARGB(255, 233, 233, 233), indent: 30, endIndent: 30,));
                      }
    }
    catch (err) {
      return Future.error(err);
    }
    return chatRooms;

  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TabTitle(title: "Messages"),
        StreamBuilder<QuerySnapshot>(stream: _conversationsStream, builder: (context, snapshot){
          if (snapshot.hasError) {
            print("error: ${snapshot.error.toString()}");
            return const Text("error");
          }

          else if (snapshot.connectionState == ConnectionState.waiting) {
            return const CenteredCircularProgressIndicator();
          }

          else {
            var chatRooms = fetchChatRoomsData(snapshot.data!.docs);
            return FutureBuilder(future: chatRooms, builder: (context, snapshot) {
              if (snapshot.hasError) {
                print("Error 1");
                print(snapshot.error.toString());
                return Text("error");
              }
              else if (snapshot.connectionState == ConnectionState.waiting){
                return CenteredCircularProgressIndicator();
              }

              else {
                return Expanded(
                    child: ListView(
                      children: snapshot.data!,
                    ));
              }
            });

          }
        }),
      ],
    );
  }
}

class ConversationPreview extends StatelessWidget {
  const ConversationPreview({
    super.key,
    required this.recipient,
    required this.carName,
    required this.lastMessage,
    required this.recipientProfilePictureUrl,
    required this.nbUnseenMessages,
    required this.onTap
  });
  final VoidCallback onTap;
  final String recipient;
  final String carName;
  final String lastMessage;
  final String recipientProfilePictureUrl;
  final int nbUnseenMessages;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Row(
            
            children: [
            ClipRRect(borderRadius: BorderRadius.circular(50), child: Image.network(recipientProfilePictureUrl, width: 40, height: 40, fit: BoxFit.cover)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Text(recipient, style: GoogleFonts.roboto(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 12),),
                  Text(" | ", style: GoogleFonts.roboto(fontWeight: FontWeight.w100, fontSize: 12),),
                  Text(carName, style: GoogleFonts.roboto(fontWeight: FontWeight.w300, fontSize: 12),)
                ],),
                Container(width: MediaQuery.of(context).size.width - 120, child: Text(lastMessage, style: GoogleFonts.roboto(fontWeight: (nbUnseenMessages == 0) ? FontWeight.normal :  FontWeight.bold, color: Colors.black, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis,))
              ],),
            )
          ],),
          nbUnseenMessages > 0 ? Padding(
            padding: const EdgeInsets.only(right: 16, left: 8),
            child: Container(child: SizedBox(child: Center(child: Text(nbUnseenMessages.toString(), style: GoogleFonts.roboto(color: Colors.white, fontSize: 10),)), width: 16, height: 16,), decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: onPrimary)),
          ) : const SizedBox(width: 0)
        ],),
      ),
    );
  }
}