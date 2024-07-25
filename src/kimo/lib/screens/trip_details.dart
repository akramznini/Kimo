import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kimo/classes/car.dart';
import 'package:kimo/classes/listing.dart';
import 'package:kimo/classes/listing_owner.dart';
import 'package:kimo/classes/trip.dart';
import 'package:kimo/screens/listing_details.dart';
import 'package:kimo/utils/helper_functions.dart';
import 'package:kimo/utils/theme_values.dart';
import 'package:kimo/widgets/buttons.dart';
import 'package:kimo/widgets/widgets.dart';


class TripDetails extends StatefulWidget {
  const TripDetails({
    super.key,
    required this.trip
  });
  final Trip trip;
  

  @override
  State<TripDetails> createState() => _TripDetailsState();
}

class _TripDetailsState extends State<TripDetails> {

  late Future<ListingOwner> fetchHost;
  var db = FirebaseFirestore.instance;

  Future<void> cancelTrip(Trip trip) async {
    try {
    await db.collection("trips").doc(trip.tripDocId).delete();
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
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: fetchHost, builder: (context, snapshot) {
      if (snapshot.hasData) {
        ListingOwner listingOwner = snapshot.data!;
        return Scaffold(
          body: Stack( children: [
            Column(
              children: [
                TabTitle(title: "Trip Details"),
                Expanded(
                  child: ListView(
                    children: [
                      SizedBox(height: 20,),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Row(children: [
                            Stack(
                              children: [
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(listingOwner!.profilePictureUrl, width: 40, height: 40, fit: BoxFit.cover,),),
                                    Positioned(
                                      child: Container(decoration: BoxDecoration(color: Color.fromARGB(255, 244, 244, 244), boxShadow: [BoxShadow(offset: Offset(0, 4), blurRadius: 4, spreadRadius: 0, color: Color.fromARGB(80, 0, 0, 0))],borderRadius: BorderRadius.circular(4)), child: Padding(
                                      padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                                      child: Row(children: [Text(listingOwner!.rating.toString(), style: robotoSmall,), SizedBox(width: 2,),Icon(Icons.star, color: onPrimary, size: 8,)],),
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
                          
                          ],),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 16),
                        child: Text("Car booked", style: boldRobotoBlack,),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) {return ListingDetails(carDocPath: widget.trip.carDocPath);}));},
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
                      Padding(
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
                            GestureDetector(
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
                                                       });
                                              print("deleted success");
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
                Padding(
                 padding: const EdgeInsets.only(left: 32, right: 32),
                 child: Divider(color: Color.fromARGB(255, 233, 233, 233),),
               ),
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Column(
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
               ),
               Padding(
                 padding: const EdgeInsets.only(left: 32, right: 32),
                 child: Divider(color: Color.fromARGB(255, 233, 233, 233),),
               ),
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Column(
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
                      child: Text("${widget.trip.duration} x ${widget.trip.dailyRate.toInt()} \$ / Day = ${widget.trip.duration*widget.trip.dailyRate} \$", style: robotoSmall2,),
                    ),
                    SizedBox(height: 8,),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text("Total", style: boldRobotoSmall2,),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text("${widget.trip.duration*widget.trip.dailyRate} \$", style: robotoSmall2,),
                    ),
                  ],
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.only(left: 32, right: 32),
                 child: Divider(color: Color.fromARGB(255, 233, 233, 233),),
               ),

                    ],))
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

    });
  }
}