import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kimo/classes/listing_owner.dart';
import 'package:kimo/classes/trip.dart';
import 'package:kimo/utils/theme_values.dart';
import 'package:kimo/widgets/buttons.dart';

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