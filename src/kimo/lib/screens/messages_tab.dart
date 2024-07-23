import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kimo/utils/theme_values.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kimo/widgets/widgets.dart';

class MessagesTab extends StatelessWidget {
  const MessagesTab({
    super.key,
    required this.user
  });
  
  final User ?user;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TabTitle(title: "Messages"),
        Expanded(
          child: ListView(
            children: [
              ConversationPreview(recipient: "Jamal", carName: "Volkswagen Beetle", lastMessage: "your car is ready for pick up! You fill find the keys in the box below",
            recipientProfilePicturePath: "assets/images/profile-picture.jpeg", nbUnseenMessages: 0,),
            ConversationPreview(recipient: "Jamal", carName: "Volkswagen Beetle", lastMessage: "your car is ready for pick up! You fill find the keys in the box below",
            recipientProfilePicturePath: "assets/images/profile-picture.jpeg", nbUnseenMessages: 3,),
            ConversationPreview(recipient: "Jamal", carName: "Volkswagen Beetle", lastMessage: "your car is ready for pick up! You fill find the keys in the box below",
            recipientProfilePicturePath: "assets/images/profile-picture.jpeg", nbUnseenMessages: 3,),
            ConversationPreview(recipient: "Jamal", carName: "Volkswagen Beetle", lastMessage: "your car is ready for pick up! You fill find the keys in the box below",
            recipientProfilePicturePath: "assets/images/profile-picture.jpeg", nbUnseenMessages: 3,),
            ConversationPreview(recipient: "Jamal", carName: "Volkswagen Beetle", lastMessage: "your car is ready for pick up! You fill find the keys in the box below",
            recipientProfilePicturePath: "assets/images/profile-picture.jpeg", nbUnseenMessages: 3,),
            ConversationPreview(recipient: "Jamal", carName: "Volkswagen Beetle", lastMessage: "your car is ready for pick up! You fill find the keys in the box below",
            recipientProfilePicturePath: "assets/images/profile-picture.jpeg", nbUnseenMessages: 3,),
            ConversationPreview(recipient: "Jamal", carName: "Volkswagen Beetle", lastMessage: "your car is ready for pick up! You fill find the keys in the box below",
            recipientProfilePicturePath: "assets/images/profile-picture.jpeg", nbUnseenMessages: 3,),
            ConversationPreview(recipient: "Jamal", carName: "Volkswagen Beetle", lastMessage: "your car is ready for pick up! You fill find the keys in the box below",
            recipientProfilePicturePath: "assets/images/profile-picture.jpeg", nbUnseenMessages: 3,),
            ConversationPreview(recipient: "Jamal", carName: "Volkswagen Beetle", lastMessage: "your car is ready for pick up! You fill find the keys in the box below",
            recipientProfilePicturePath: "assets/images/profile-picture.jpeg", nbUnseenMessages: 3,),
          ]),
        ),
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
    required this.recipientProfilePicturePath,
    required this.nbUnseenMessages
  });

  final String recipient;
  final String carName;
  final String lastMessage;
  final String recipientProfilePicturePath;
  final int nbUnseenMessages;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        Row(
          
          children: [
          ClipRRect(borderRadius: BorderRadius.circular(50), child: Image.asset(recipientProfilePicturePath, width: 40, height: 40, fit: BoxFit.cover)),
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
    );
  }
}