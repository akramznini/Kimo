import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kimo/classes/address.dart';
import 'package:kimo/classes/listing_owner.dart';
import 'package:kimo/classes/review.dart';
import 'package:kimo/classes/trip.dart';
import 'package:kimo/utils/helper_functions.dart';
import 'package:kimo/utils/theme_values.dart';
import 'package:kimo/widgets/buttons.dart';

import '../classes/city.dart';

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
    required this.title,
    this.size = 16
  });
  final double size;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(title, style: GoogleFonts.roboto(color: Colors.black, fontSize:  size, fontWeight: FontWeight.bold)),
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


class ReviewPreviewContainer extends StatelessWidget {
  const ReviewPreviewContainer({
    super.key,
    required this.review,
    required this.name,
    required this.profilePictureUrl
  });

  final Review review;
  final String name;
  final String profilePictureUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: greySelected, width: 0.5), borderRadius: BorderRadius.circular(15)),
      width: 240,
      height: 150,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
            children: [
              Text(review.rating.toStringAsFixed(1), style: lightRoboto),
              Padding(
                padding: const EdgeInsets.only(left: 2, right: 2),
                child: Icon(Icons.star, color: onPrimary, size: 12),
              ),
            ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(review.content, style: blackRobotoRegular, maxLines: 4,),
            ),
            Row(
              children: [
                ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(profilePictureUrl, width: 40, height: 40, fit: BoxFit.cover,),),
                SizedBox(width: 10,),
                Text(name, style: boldRobotoBlack)
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CitySelector extends StatefulWidget {
  const CitySelector ({
    super.key,
    required this.controller,
    required this.cities,
    required this.style,
    required this.textAlign,
    required this.decoration,
    required this.tileStyle
  });
  final TextStyle style;
  final TextStyle tileStyle;
  final TextAlign textAlign;
  final InputDecoration decoration;
  final TextEditingController controller;
  final List<City> cities;
  @override
  _CitySelectorState createState() => _CitySelectorState();
}

class _CitySelectorState extends State<CitySelector> {
  
  String selectedCity = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              List<String> cityNames = widget.cities.map((element) => "${element.name}").toList();
              widget.controller.text = textEditingValue.text;
              if (textEditingValue.text.isEmpty) {
                return cityNames;
              }
              return cityNames.where((String city) {
                return city.toLowerCase().contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (String selection) {
              setState(() {
                selectedCity = selection;
                widget.controller.text = selection;
              });
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  child: Container(
                    width: 230,
                    color: Colors.white,
                    child: ClipRRect(

                      borderRadius: BorderRadius.circular(30),
                      child: ListView.builder(
                        
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final String option = options.elementAt(index);
                            
                          return GestureDetector(
                            onTap: () {
                              onSelected(option);
                            },
                            child: ListTile(
                              title: Center(
                                child: Text(
                                  option,
                                  style: widget.tileStyle,
                                ),
                              ),
                              tileColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
            fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
                FocusNode focusNode, VoidCallback onFieldSubmitted) {
              return TextFormField(
                controller: textEditingController,
                focusNode: focusNode,
                style: widget.style,
                textAlign: widget.textAlign,
                decoration: widget.decoration,
              );
            },
          ),
        ],
      ),
    );
  }
}


class FilterSelector extends StatefulWidget {
  const FilterSelector ({
    super.key,
    this.enabled = true,
    required this.controller,
    required this.elements,
    this.label,
    this.suffix,
    this.keyboardType,
    this.inputFormatters,
    this.onSelected,
    required this.tileTextAlign,
  });
  final bool enabled;
  final TextInputType ?keyboardType;
  final List<TextInputFormatter> ?inputFormatters;
  final String ?suffix;
  final Widget ?label;
  final TextAlign tileTextAlign;
  final TextEditingController controller;
  final List<String> elements;
  final VoidCallback ?onSelected;
  
  @override
  _FilterSelectorState createState() => _FilterSelectorState();
}

class _FilterSelectorState extends State<FilterSelector> {
  
  String selectedCity = '';
  int state = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              widget.controller.text = textEditingValue.text;
              if (textEditingValue.text.isEmpty) {
                return widget.elements;
              }
              return widget.elements.where((String element) {
                return element.toLowerCase().contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (String selection) {
              print("onSelected");
              setState(() {
                selectedCity = selection;
                widget.controller.text = selection;
                if (widget.onSelected != null) {
                  widget.onSelected!();
                }
              });
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  child: Container(
                    color: Colors.white,
                    child: ClipRRect(
    
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 120,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final String option = options.elementAt(index);
                              
                            return GestureDetector(
                              onTap: () {
                                onSelected(option);
                              },
                              child: ListTile(
                                title: Center(
                                  child: Text(
                                    option,
                                    style: GoogleFonts.roboto(color: Color.fromARGB(255, 0, 0, 0)),
                                  ),
                                ),
                                tileColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
                FocusNode focusNode, VoidCallback onFieldSubmitted) {
              return Container(
    
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: greySelected),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextFormField(
                    enabled: widget.enabled,
                    controller: textEditingController,
                    focusNode: focusNode,
                    style: blackRobotoRegular,
                    textAlign: widget.tileTextAlign,
                    keyboardType: widget.keyboardType,
                    inputFormatters: widget.inputFormatters,
                    decoration: InputDecoration(label: widget.label, labelStyle: boldRobotoBlack, border: InputBorder.none, suffix: widget.suffix==null ? null : Text(widget.suffix!, style: boldRobotoBlack,)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

