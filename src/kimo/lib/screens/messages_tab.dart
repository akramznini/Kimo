import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
    required this.user,
    required this.goToTab
  });
  final void Function(int) goToTab;
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
    if (FirebaseAuth.instance.currentUser != null) {
      _conversationsStream = FirebaseFirestore.instance.collection("chat_rooms").where("guest_uid", isEqualTo: widget.user!.uid).snapshots();
    }
  }

  Future<List<Widget>> generateChatRoomWidgets(List<QueryDocumentSnapshot> docs) async {
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
                        var messagesQuerySnapshot = await FirebaseFirestore.instance.collection("chat_rooms").doc(document.id).collection("messages").orderBy("timestamp", descending: true).limit(1).get();
                        print("line6");
                        Message ?message;
                        if (messagesQuerySnapshot.size != 0) {
                          message = Message.fromFirestore(messagesQuerySnapshot.docs.first);
                        }
                        
                        if (message != null) {
                            chatRooms.add(ConversationPreview(onTap:(){
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) {return ConversationPage(chatDocId: document.id, recipient: recipient, trip: trip, user: widget.user!,);})).then((value) async {
                            await FirebaseFirestore.instance.collection("chat_rooms").doc(document.id).update({'guest_unseen_messages': 0});
                          });
                        }, recipient: recipient.firstName, carName: "${trip.carBrand} ${trip.carModel}", carImgUrl: trip.pictureUrl, lastMessage: message!.content, recipientProfilePictureUrl: recipient.profilePictureUrl, nbUnseenMessages: chatRoom.guestUnseenMessages));
                        print("line7");
                        chatRooms.add(Divider(color: Color.fromARGB(255, 233, 233, 233), indent: 30, endIndent: 30,));
                        }
                        
                      }
    }
    catch (err) {
      return Future.error(err);
    }
    return chatRooms;

  }
  @override
  Widget build(BuildContext context) {
    if (widget.user != null) {
    
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
            var chatRooms = generateChatRoomWidgets(snapshot.data!.docs);
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
                if (snapshot.data!.isEmpty) {
                  return Expanded(child: Center(child: Text("There are no messages to display.", style: blackRobotoRegular,)));
                }
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
    } else {
      var content = ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(width: 1, color: greySelected)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset("assets/icons/message-icon.svg", width: 40, height: 40,),
                      ),
                      Text("Messages", style: robotoLargerBlack,),
                      Text("Sign in to see messages!", style: lightRoboto, textAlign: TextAlign.center,),
                      SizedBox(height: 20,),
                      ElevatedButton(onPressed: (){widget.goToTab(4);}, child: Container(height: 20, width: 120, child: Center(child: Text("SIGN IN", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),))), style: ElevatedButton.styleFrom(backgroundColor: onPrimary),),
                      SizedBox(height: 20,),
                    ],),
                  ),
                ),
              ),
            ],
          );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          TabTitle(title: "Wishlist"),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: content,
            )),

        ],);

    }

    
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
    required this.onTap,
    required this.carImgUrl
  });
  final String carImgUrl;
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
            Container(
              width: 50,
              height: 50,
              child: Stack(
                children: [
                  ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(carImgUrl, width: 40, height: 40, fit: BoxFit.cover)),
                  Positioned(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2), borderRadius: BorderRadius.circular(50)), child: ClipRRect(borderRadius: BorderRadius.circular(50), child: Image.network(recipientProfilePictureUrl, width: 30, height: 30, fit: BoxFit.cover))), right: 0, bottom: 0,),
                  
                ],
              ),
            ),
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