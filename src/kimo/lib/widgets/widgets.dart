import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kimo/classes/address.dart';
import 'package:kimo/classes/listing_owner.dart';
import 'package:kimo/classes/trip.dart';
import 'package:kimo/utils/helper_functions.dart';
import 'package:kimo/utils/theme_values.dart';
import 'package:kimo/widgets/buttons.dart';

void showCustomToast(BuildContext context, String message) {
  OverlayEntry overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 50.0,
      left: MediaQuery.of(context).size.width * 0.1,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            message,
            style: TextStyle(color: Colors.white, fontSize: 16.0),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );

  Overlay.of(context).insert(overlayEntry);

  Future.delayed(Duration(seconds: 2), () {
    overlayEntry.remove();
  });
}

class HostPreviewContainer extends StatelessWidget {
  const HostPreviewContainer({
    super.key,
    required this.listingOwner,
  });

  final ListingOwner listingOwner;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
        Stack(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(listingOwner!.profilePictureUrl, width: 40, height: 40, fit: BoxFit.cover,),),
                Positioned(
                  child: Container(decoration: BoxDecoration(color: Color.fromARGB(255, 244, 244, 244), boxShadow: [BoxShadow(offset: Offset(0, 4), blurRadius: 4, spreadRadius: 0, color: Color.fromARGB(80, 0, 0, 0))],borderRadius: BorderRadius.circular(4)), child: Padding(
                  padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                  child: Row(children: [Text(listingOwner!.rating.toStringAsFixed(1), style: robotoSmall,), SizedBox(width: 2,),Icon(Icons.star, color: onPrimary, size: 8,)],),
                )), bottom: 0, left: 4,)
                
                ],
        ),
      Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(children: [
            Text("Hosted by ", style: boldRobotoBlack,),
            Text(listingOwner!.firstName, style: lightRoboto)
          ],),
          Text("${listingOwner!.nbTrips} trips given", style: lightRobotoSmall)
        ],),
      )
      
      ],);
  }
}





class CenteredCircularProgressIndicator extends StatelessWidget {
  const CenteredCircularProgressIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(child: Container(width: 50, height: 50 ,child: CircularProgressIndicator()));
  }
}

class TabTitle extends StatelessWidget {
  const TabTitle({
    super.key,
    required this.title
  });
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(title, style: GoogleFonts.roboto(color: Colors.black, fontSize:  16, fontWeight: FontWeight.bold)),
            );
  }
}


class MessageContainer extends StatelessWidget {
  const MessageContainer({
    super.key,
    required this.color,
    required this.textColor,
    required this.content
  });
  final Color textColor;
  final String content;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
    child: Padding(
    padding: const EdgeInsets.only(top: 6.0, bottom: 6.0, left: 8, right: 8),
    child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 200), child: Text(content, style: GoogleFonts.roboto(fontSize: 13, fontWeight: FontWeight.w400, color: textColor, decoration: TextDecoration.none))),
          ), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20), ),);
  }
}


class SendButton extends StatelessWidget {
  const SendButton({
    super.key,
    required this.onClick
  });
  final VoidCallback onClick;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onClick, child: SvgPicture.asset("assets/icons/messages-send-icon.svg", height: 30, width: 30,));
  }
}

class ConversationHeader extends StatefulWidget {
  const ConversationHeader({
    super.key,
    required this.recipient,
    required this.trip,
    this.bgColor = Colors.white,
  });
  final Color bgColor;
  final Trip trip;
  final ListingOwner recipient;

  @override
  State<ConversationHeader> createState() => _ConversationHeaderState();
}

class _ConversationHeaderState extends State<ConversationHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: widget.bgColor, boxShadow: [BoxShadow(color: greySelected, blurRadius: 10, spreadRadius: 10)]),
      height: 50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            BackArrowButton(),
            SizedBox(width: 16,),
            ClipRRect(borderRadius: BorderRadius.circular(30), child: Image.network(widget.recipient.profilePictureUrl, width: 30, height: 30, fit: BoxFit.cover)),
            SizedBox(width: 8,),
            Text(widget.recipient.firstName, style: GoogleFonts.roboto(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 12),),
            Text(" | ", style: GoogleFonts.roboto(fontWeight: FontWeight.w100, fontSize: 12),),
            Text("${widget.trip.carBrand} ${widget.trip.carModel}", style: GoogleFonts.roboto(fontWeight: FontWeight.w300, fontSize: 12),)
        
          ],
        ),
      ),
    );
  }
}

class MessageInput extends StatefulWidget {
  const MessageInput({
    super.key,
    required this.onSendClick,
    required this.controller
  });
  final TextEditingController controller;
  final VoidCallback onSendClick;
  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  bool sendButtonEnabled = false;
  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    widgets.add(Expanded(
      child: Container(
        decoration: BoxDecoration(color: greySelected, borderRadius: BorderRadius.circular(15)), child: TextField(maxLines: 4, minLines: 1, style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.normal), decoration: InputDecoration(isDense: true, border: InputBorder.none, hintText: "Message...", contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10)), controller: widget.controller, onChanged: (value) {
        if (value.isEmpty){
          if (sendButtonEnabled) {
            setState(() {
              sendButtonEnabled = false;
            });
          }
        }
        else {
          if (!sendButtonEnabled) {
            setState(() {
              sendButtonEnabled = true;
            });
          }
        }
      },)),
    ));
    if (sendButtonEnabled) widgets.add(Padding(
      padding: const EdgeInsets.only(left: 8),
      child: SendButton(onClick: widget.onSendClick),
    ));
    return Row(
      children: widgets,
    );
  }
}

class locationPreviewContainer extends StatelessWidget {
  const locationPreviewContainer({
    super.key,
    required this.address,
    required this.latitude,
    required this.longitude
  });

  final Address address;
  final double latitude;
  final double longitude;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){openMap(latitude, longitude);},
      child: Row(
       
       children: [
       Icon(Icons.location_on_outlined, size: 24, color: onPrimary,),
       SizedBox(width: 12,),
       Text("${address.streetNumber}, ${address.city}", style: lightRoboto,)
      ],),
    );
  }
}