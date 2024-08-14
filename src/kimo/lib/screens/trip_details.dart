import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kimo/classes/car.dart';
import 'package:kimo/classes/chat_room.dart';
import 'package:kimo/classes/listing.dart';
import 'package:kimo/classes/listing_owner.dart';
import 'package:kimo/classes/trip.dart';
import 'package:kimo/screens/conversation_page.dart';
import 'package:kimo/screens/listing_details.dart';
import 'package:kimo/utils/helper_functions.dart';
import 'package:kimo/utils/theme_values.dart';
import 'package:kimo/widgets/buttons.dart';
import 'package:kimo/widgets/widgets.dart';

class TripDetails extends StatefulWidget {
  const TripDetails({
    super.key,
    required this.trip,
    required this.goToTab
  });
  final void Function(int) goToTab;
  final Trip trip;
  

  @override
  State<TripDetails> createState() => _TripDetailsState();
}

class _TripDetailsState extends State<TripDetails> {
  late ListingOwner listingOwner;
  late bool tripIsReviewed;
  late Future<ListingOwner> fetchHost;
  var db = FirebaseFirestore.instance;

  Future<void> openConversation() async {
    
    if (FirebaseAuth.instance.currentUser != null) {
      try {
      String chatDocId;
      String userUID = FirebaseAuth.instance.currentUser!.uid;
      var querySnapshot = await db.collection("chat_rooms").where("trip_doc_path", isEqualTo: "trips/${widget.trip.tripDocId}").get();
      var host = await db.collection("users").doc(widget.trip.hostId).get();
      ListingOwner recipient = ListingOwner.fromFirestore(host);
      if (querySnapshot.docs.isNotEmpty){
        chatDocId = querySnapshot.docs.first.id;
      }
      else {
        String hostUID = host.data()!["UID"];
        ChatRoom chatRoom = ChatRoom(guestUid: userUID, guestUnseenMessages: 0, hostUid: hostUID, hostUnseenMessages: 0, tripDocPath: "trips/${widget.trip.tripDocId}");
        var docReference = await db.collection("chat_rooms").add(chatRoom.toMap());
        chatDocId = docReference.id;
      }
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return ConversationPage(chatDocId: chatDocId, trip: widget.trip, recipient: recipient, user: FirebaseAuth.instance.currentUser!);
      }));
      }
      catch (e) {
        print("openConversation Error: ${e}");
      }
    }
    
  } 
  
  
  
  Future<void> cancelTrip(Trip trip) async {
    try {
    await db.collection("trips").doc(trip.tripDocId).update({"is_cancelled": true});
    var listing1DocSnapshot = await db.collection("listings").where("car", isEqualTo: trip.carDocPath).where("end_date", isEqualTo: trip.startDate).get();
    var listing2DocSnapshot = await db.collection("listings").where("car", isEqualTo: trip.carDocPath).where("start_date", isEqualTo: trip.endDate).get();
    if (listing1DocSnapshot.docs.isNotEmpty && listing2DocSnapshot.docs.isNotEmpty) {
      Listing listing1 = Listing.fromFirestore(listing1DocSnapshot.docs.first);
      Listing listing2 = Listing.fromFirestore(listing2DocSnapshot.docs.first);
      listing1.endDate = listing2.endDate;
      await db.collection("listings").doc(listing1.docId).update(listing1.toMap());
      await db.collection("listings").doc(listing2.docId).delete();
    }

    else if (listing1DocSnapshot.docs.isNotEmpty) {
      Listing listing1 = Listing.fromFirestore(listing1DocSnapshot.docs.first);
      listing1.endDate = trip.endDate;
      await db.collection("listings").doc(listing1.docId).update(listing1.toMap());
    }

    else if (listing2DocSnapshot.docs.isNotEmpty){
      Listing listing2 = Listing.fromFirestore(listing2DocSnapshot.docs.first);
      listing2.startDate = trip.endDate;
      await db.collection("listings").doc(listing2.docId).update(listing2.toMap());
    }

    else {
      Car car = Car.fromFirestore(await db.doc(trip.carDocPath).get());
      Listing listing = Listing(city: car.address.city.toLowerCase(), docId: '', brand: car.brand, model: car.model, carId: trip.carDocPath, dailyRate: car.dailyRate, endDate: trip.endDate, nbReviews: car.nbReviews, nbSeats: car.nbSeats, positionLatitude: car.location.latitude, positionLongitude: car.location.longitude, rating: car.rating, startDate: trip.startDate, pictureUrl: car.pictures[0]);
      await db.collection("listings").add(listing.toMap());
    }
    
    // implement in Cloud Functions
    await db.collection("users").doc(listingOwner.docId).update({"nb_trips" : listingOwner.nbTrips - 1});

    }
    catch (err) {
      return Future.error(err);
    }
  }

  Future<ListingOwner> fetchHostData() async {
    User ?user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        
      var listingOwnerDoc = await db.collection("users").doc(widget.trip.hostId).get();
      ListingOwner listingOwner = ListingOwner.fromFirestore(listingOwnerDoc);
      return listingOwner;
      }
      catch (err) {
        return Future.error(err);
      }
      
    }
    else {
      return Future.error("user not signed in");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchHost = fetchHostData();
    tripIsReviewed = widget.trip.isReviewed;
  }
  @override
  Widget build(BuildContext context) {
    print("trip end: ${widget.trip.endDate.millisecondsSinceEpoch}");
    print("now: ${Timestamp.now().millisecondsSinceEpoch}");
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(future: fetchHost, builder: (context, snapshot) {
          if (snapshot.hasData) {
            listingOwner = snapshot.data!;
            return Scaffold(
              body: Stack( children: [
                Column(
                  children: [
                    TabTitle(title: "Trip Details"),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView(
                          children: [
                            SizedBox(height: 20,),
        
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: HostPreviewContainer(listingOwner: listingOwner),
                            ),
                            SizedBox(height: 8,),
                            Text("Car booked", style: boldRobotoBlack,),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: GestureDetector(
                                onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) {return ListingDetails(goToTab: widget.goToTab, carDocPath: widget.trip.carDocPath);}));},
                                child: Row(children: [
                                  ClipRRect(
                                              borderRadius: BorderRadius.circular(20),
                                              child: Image.network(widget.trip.pictureUrl, width: 40, height: 40, fit: BoxFit.cover,),),
                                  Padding(
                                    padding: const EdgeInsets.only(left:8.0),
                                    child: Text("${widget.trip.carBrand} ${widget.trip.carModel}", style: boldRobotoBlack,),
                                  ),
                                  
                                ],),
                              ),
                            ),
                            Padding(
                                         padding: const EdgeInsets.only(left: 32, right: 32),
                                         child: Divider(color: Color.fromARGB(255, 233, 233, 233),),
                                       ),
                        
                            GestureDetector(
                              onTap: openConversation,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset("assets/icons/navbar-messages.svg", height: 35, width: 35),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 6.0),
                                          child: Text("Send a message", style: boldRobotoSmall,),
                                        )
                                      ],
                                    ),
                                  const VerticalDivider(
                                          width: 20,
                                          thickness: 1,
                                          indent: 20,
                                          endIndent: 0,
                                          color: Colors.grey,
                                        ),
                                    (widget.trip.isCancelled || widget.trip.endDate.millisecondsSinceEpoch < Timestamp.now().millisecondsSinceEpoch) ? SizedBox() : GestureDetector(
                                      onTap: (){
                                        showDialog(context: context, barrierDismissible: true, builder: (context) {
                                          return AlertDialog(
                                            title: Text('Trip cancellation', style: robotoLargerBlack,),
                                            content: Text("Are you sure you want to cancel the trip?"),
                                            actions: [
                                              TextButton(onPressed: (){
                                                Navigator.of(context).pop();
                                                showDialog(context: context, builder: (context) {
                                                  return FutureBuilder(future: cancelTrip(widget.trip), builder: (context, snapshot) {
                                                    if (snapshot.connectionState == ConnectionState.done) {
                                                      Future.delayed(Duration.zero, () {
                                                      Navigator.of(context).pop();
                                                               }).then((onValue){showCustomToast(context, "Your booking is cancelled.");});
                                                      print("deleted success");
                                                      
                                                      Navigator.of(context).pop();
                                                      return SizedBox.shrink();
                                                    }
                                                    else if (snapshot.hasError) {
                                                        Future.delayed(Duration.zero, () {
                                                      Navigator.of(context).pop();
                                                               });
                                                      print(snapshot.error.toString());
                                                      return SizedBox.shrink();
                                                    }
                              
                                                    else {
                                                        return CenteredCircularProgressIndicator();
                                                    }
                                                  });
                                                });
                                              }, child: Text("Yes", style: robotoLargePrimary)),
                                              TextButton(onPressed: (){Navigator.of(context).pop();}, child: Text("No", style: robotoLargePrimary,),)
                                            ],
                                          );
                                        });
                                      },
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset("assets/icons/cancel.svg", height: 35, width: 35),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 6.0),
                                            child: Text("Cancel trip", style: boldRobotoSmall,),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                                        (tripIsReviewed || widget.trip.endDate.millisecondsSinceEpoch > Timestamp.now().millisecondsSinceEpoch || widget.trip.isCancelled || 
                                        DateTime.fromMillisecondsSinceEpoch(widget.trip.endDate.millisecondsSinceEpoch).add(Duration(days: 7)).millisecondsSinceEpoch < DateTime.now().millisecondsSinceEpoch)
                                         ? SizedBox() : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Padding(
                                         padding: const EdgeInsets.only(left: 32, right: 32),
                                         child: Divider(color: Color.fromARGB(255, 233, 233, 233),),
                                       ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text('Leave a review', style: boldRobotoSmall2,),
                          ),
                          Center(
                            child: RatingBar(
                              ratingWidget: RatingWidget(full: Icon(Icons.star, color: onPrimary, ), half: Icon(Icons.star, color: onPrimary,), empty: Icon(Icons.star_border, color: onPrimary,)), 
                              allowHalfRating: false,
                              itemSize: 30,
                              onRatingUpdate: (rating){
                                TextEditingController controller = TextEditingController();
                                double currentRating = rating;
                                showDialog(context: context, builder: (context) {
                                  return Dialog(
                                    child: Container(
                                      height: 260,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                          
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: RatingBar(ratingWidget: RatingWidget(full: Icon(Icons.star, color: onPrimary, ), half: Icon(Icons.star, color: onPrimary,), empty: Icon(Icons.star_border, color: onPrimary,)), itemSize: 30, 
                                              initialRating: currentRating, onRatingUpdate: (rating){currentRating = rating;}),
                                            ),
                                          ),
                                          SizedBox(height: 20,),
                                          Text("Leave a comment", style: blackRobotoRegular,),
                                          SizedBox(height: 8,),
                                          Container(decoration: BoxDecoration(border: Border.all(color: greySelected, width: 1), borderRadius: BorderRadius.circular(15)),
                                            child: TextField(maxLines: 4, style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.normal), decoration: InputDecoration(isDense: true, border: InputBorder.none, hintText: "Comment...", contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10)), controller: controller)),
                                          SizedBox(height: 20,),
                                          Center(child: ElevatedButton(onPressed: () async {
                                            try {
                                              await db.collection("reviews").add({"trip_doc_path": "trips/${widget.trip.tripDocId}", "timestamp": Timestamp.now(), "rating": currentRating, "reviewer": widget.trip.guestId, "reviewee": widget.trip.hostId, "content": controller.text});
                                              await db.collection("trips").doc(widget.trip.tripDocId).update({"is_reviewed": true});
                                              /* Implement the following code in Cloud Functions */
                                              // update reviews in users collection
                                              await db.collection("users").doc(widget.trip.hostId).update({"nb_reviews": listingOwner.nbReviews + 1, "rating": (listingOwner.rating*listingOwner.nbReviews + currentRating) / (listingOwner.nbReviews + 1)});
                                              // update reviews in cars collection
                                              Car car = Car.fromFirestore(await db.doc(widget.trip.carDocPath).get());
                                              int carNbReviews = car.nbReviews + 1;
                                              double carRating =  (car.rating*car.nbReviews + currentRating) / (car.nbReviews + 1);
                                              await db.doc(widget.trip.carDocPath).update({"nb_reviews": carNbReviews, "rating": carRating});
                                              // update reviews in listings collection
                                              var listingsSnapshot = await db.collection("listings").where("car", isEqualTo: widget.trip.carDocPath).get();
                                              for (var doc in listingsSnapshot.docs) {
                                                String docId = doc.id;
                                                await db.collection("listings").doc(docId).update({"nb_reviews": carNbReviews, "rating": carRating});
                                              }
                                              
                                              /* End */
                                              showCustomToast(context, "Thank you for submitting your review!");
                                              setState(() {
                                                tripIsReviewed = true;
                                              });
                                            }
                                            catch (e) {
                                              print("'Send Review OnPressed' error: ${e}");
                                              showCustomToast(context, "There was a problem submitting your review.");
                                            }
                                            Navigator.pop(context);
                                            
                                          }, child: Container(height: 20, width: 120, child: Center(child: Text("Send Review", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),))), style: ElevatedButton.styleFrom(backgroundColor: onPrimary),))
                                        ],),
                                      ),
                                    ),
                                  );
                                });
                        
                              }),
                          )
                        ],),
                                        ),
                                       Padding( 
                                         padding: const EdgeInsets.only(left: 32, right: 32),
                                         child: Divider(color: Color.fromARGB(255, 233, 233, 233),),
                                       ),
                                       Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text("Location", style: boldRobotoSmall2),
                        ),
                                       Padding(
                                         padding: const EdgeInsets.symmetric(vertical: 8.0),
                                         child: locationPreviewContainer(address: widget.trip.address, latitude: widget.trip.positionLatitude, longitude: widget.trip.positionLongitude),
                                       ),
                                        Padding( 
                                         padding: const EdgeInsets.only(left: 32, right: 32),
                                         child: Divider(color: Color.fromARGB(255, 233, 233, 233),),
                                       ),
                                       Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text("Dates", style: boldRobotoSmall2),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(dateTimeToString(DateTime.fromMillisecondsSinceEpoch(widget.trip.startDate.millisecondsSinceEpoch)), style: robotoSmall2,),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(dateTimeToString(DateTime.fromMillisecondsSinceEpoch(widget.trip.endDate.millisecondsSinceEpoch)), style: robotoSmall2,),
                        ),
                                        ],
                                       ),
                                       Padding(
                                         padding: const EdgeInsets.only(left: 32, right: 32),
                                         child: Divider(color: Color.fromARGB(255, 233, 233, 233),),
                                       ),
                                       Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text("Payment Info", style: boldRobotoSmall2,),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text("Rental", style: boldRobotoSmall2,),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text("${widget.trip.isCancelled ? 0 : widget.trip.duration} x ${widget.trip.dailyRate.toInt()} \$ / Day = ${(widget.trip.isCancelled ? 0 : widget.trip.duration)*widget.trip.dailyRate} \$", style: robotoSmall2,),
                        ),
                        SizedBox(height: 8,),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text("Total", style: boldRobotoSmall2,),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text("${(widget.trip.isCancelled ? 0 : widget.trip.duration)*widget.trip.dailyRate} \$", style: robotoSmall2,),
                        ),
                                        ],
                                       ),
                                       Padding(
                                         padding: const EdgeInsets.only(left: 32, right: 32),
                                         child: Divider(color: Color.fromARGB(255, 233, 233, 233),),
                                       ),
                        
                          ],),
                      ))
                  ],
                ),
                Positioned(
                    top: 10,
                    left: 10,
                    child: CustomButtonWhite(iconSize: 20, icon:Icon(Icons.arrow_back), onPressed: (){Navigator.pop(context);},))
              ],
              ),
            );
          }
        
          else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
        
          else {
            return CenteredCircularProgressIndicator();
          }
        
        }),
      ),
    );
  }
}

