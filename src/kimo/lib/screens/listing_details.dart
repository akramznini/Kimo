import 'dart:math';

import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kimo/classes/address.dart';
import 'package:kimo/classes/car.dart';
import 'package:kimo/classes/listing.dart';
import 'package:kimo/classes/listing_owner.dart';
import 'package:kimo/classes/review.dart';
import 'package:kimo/classes/trip.dart';
import 'package:kimo/screens/home_tab.dart';
import 'package:kimo/utils/helper_functions.dart';
import 'package:kimo/utils/theme_values.dart';
import 'package:kimo/widgets/buttons.dart';
import 'package:kimo/widgets/car_widgets.dart';
import 'package:kimo/widgets/widgets.dart';

class ListingDetails extends StatefulWidget {
  ListingDetails({
    super.key,
    required this.carDocPath,
    this.dateTimeRange,
    this.listing,
    required this.goToTab
  });
  final void Function(int) goToTab;
  DateTimeRange? dateTimeRange;
  Listing? listing;
  final String carDocPath;
  late bool isFavorite;
  @override
  State<ListingDetails> createState() => _ListingDetailsState();

}


class _ListingDetailsState extends State<ListingDetails> {
  User? currentUser;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    Car ?car;
    ListingOwner ?listingOwner;
    List<Review> reviews = [];
    List<Map<String, dynamic>?> reviewers = [];

    Future<void> fetchData() async {
    FirebaseAuth.instance
    .authStateChanges()
    .listen((User? user) async {
    currentUser = user;
    if (user == null) {
      widget.isFavorite = false;
      // handle user null
    } else {
      // handle user not null
      var userDoc = await db.collection("users").where("UID", isEqualTo: currentUser!.uid).get();
      var wishlist;
      try {wishlist = userDoc.docs.first.data()["wishlist"] as List;}
      catch (e) {
        wishlist = [];
      }
      
      widget.isFavorite = wishlist.contains(widget.carDocPath);
    }
    });
      try {
        if (widget.dateTimeRange == null || widget.listing == null) {

        final listingDocsResponse = await db.collection("listings").where("car", isEqualTo: widget.carDocPath)
        .where("end_date", isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now().add(Duration(days: 2)))).orderBy("start_date").limit(1).get();
        if (!listingDocsResponse.docs.isEmpty) {
          widget.listing = Listing.fromFirestore(listingDocsResponse.docs.first);
          var startDateMilliSecondsEpoch = max(widget.listing!.startDate.millisecondsSinceEpoch, Timestamp.now().millisecondsSinceEpoch);
          var tmpDate = DateTime.fromMillisecondsSinceEpoch(startDateMilliSecondsEpoch);
          var startDate = DateTime(tmpDate.year, tmpDate.month, tmpDate.day, 0, 0, 0);
          widget.dateTimeRange = DateTimeRange(start: startDate.add(Duration(days: 1)), end: startDate.add(Duration(days: 2)));
        }
        }
        DocumentSnapshot carDocResponse = await db.doc(widget.carDocPath).get();
        if (carDocResponse.exists){
          car = Car.fromFirestore(carDocResponse);
          DocumentSnapshot listingOwnerDoc = await db.collection("users").doc(car!.ownerDocId).get();
          
          listingOwner = ListingOwner.fromFirestore(listingOwnerDoc);
        }
        QuerySnapshot reviewsQuerySnapshot = await db.collection("reviews").where("reviewee", isEqualTo: listingOwner!.docId).limit(6).get();
        for (var doc in reviewsQuerySnapshot.docs) {
          Review review = Review.fromFirestore(doc);
          reviews.add(review);
          var reviewer = (await db.collection("users").doc(review.reviewer).get()).data();
          reviewers.add(reviewer);
        }
        }
      catch (e) {
        return Future.error(e.toString());
      }

    }

    /*Future<void> getAddressfromLocation(double latitude, double longitude) async {
        try {
            placemarks = await placemarkFromCoordinates(car!.location.latitude, car!.location.longitude);
        }
        catch (e){
          return Future.error("couldn't get Address");
        }
    }*/
    
    //Future<DocumentSnapshot<Map<String, dynamic>>> future = db.doc(carDocPath).get();
    Future<void> bookTrip(Listing listing, Timestamp startDate, Timestamp endDate, ) async {
      try {
        Car car = Car.fromFirestore(await db.doc(listing.carId).get());
        String userDocId = (await db.collection("users").where("UID", isEqualTo: currentUser!.uid).get()).docs.first.id;
        int duration = DateTime.fromMillisecondsSinceEpoch(endDate.millisecondsSinceEpoch).difference(DateTime.fromMillisecondsSinceEpoch(endDate.millisecondsSinceEpoch)).inDays + 1;
        Trip trip = Trip(tripDocId: '', carDocPath: listing.carId, dailyRate: listing.dailyRate, duration: duration, endDate: endDate, guestId: userDocId, hostId: car.ownerDocId, positionLatitude: listing.positionLatitude, positionLongitude: listing.positionLongitude, startDate: startDate, pictureUrl: listing.pictureUrl, carModel: car.model, carBrand: car.brand, address: car.address);
        await db.collection("trips").add(trip.toMap());
        if (listing.startDate == startDate && listing.endDate == endDate) {
          await db.collection("listings").doc(listing.docId).delete();
        }

        else if (listing.startDate == startDate) {
          listing.startDate = trip.endDate;
          await db.collection("listings").doc(listing.docId).update(listing.toMap());
        }

        else if (listing.endDate == endDate) {
          listing.endDate = trip.startDate;
          await db.collection("listings").doc(listing.docId).update(listing.toMap());

        }

        else {
          Timestamp endDate2 = listing.endDate;
          listing.endDate = trip.startDate;
          await db.collection("listings").doc(listing.docId).update(listing.toMap());

          listing.startDate = trip.endDate;
          listing.endDate = endDate2;

          await db.collection("listings").add(listing.toMap());

        }
        // Implement in Cloud Functions
        await db.collection("users").doc(listingOwner!.docId).update({"nb_trips": listingOwner!.nbTrips + 1});
        // End Cloud Functions
        
        }
        catch (err) {
          return Future.error(err);
        }
    }

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(future: fetchData(), builder: (context, snapshot){
          if (snapshot.hasError){
            print(snapshot.error);
            return Stack(children: [
              Center(child: Text("There was a problem loading data. ")),
              Positioned(
                  top: 10,
                  left: 10,
                  child: CustomButtonWhite(iconSize: 20, icon:Icon(Icons.arrow_back), onPressed: (){Navigator.pop(context);},)),]);
          }
          else if (snapshot.connectionState == ConnectionState.done){
            if (car != null && widget.dateTimeRange != null){
            int duration = widget.dateTimeRange!.end.difference(widget.dateTimeRange!.start).inDays + 1;
            List<Widget> reviewWidgets = [];
            for (int i = 0; i < reviews.length ; i++) {
              Review review = reviews[i];
              String name = reviewers[i]!["first_name"];
              String profilePictureUrl = reviewers[i]!["profile_picture_url"];
              reviewWidgets.add(Padding(
                padding: const EdgeInsets.all(8.0),
                child: ReviewPreviewContainer(review: review, name: name, profilePictureUrl: profilePictureUrl),
              ));
            }
            return Container(
              color: Colors.white,
              child: Stack(
                children: [
                ListView(children: [
                   SizedBox(
                    height: 200,
                    width: double.minPositive,
                     child: AnotherCarousel(
                      dotSize: 4,
                      dotBgColor: Color.fromARGB(0, 233, 233, 233),
                      dotIncreaseSize: 2,
                      indicatorBgPadding: 10,
                      autoplay: false,
                      images: car!.pictures.map((url){return Image.network(url, fit: BoxFit.cover,);}).toList()),
                   ),
                   Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: Text("${car!.brand} ${car!.model}", style: GoogleFonts.roboto(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold, decoration: TextDecoration.none),),
                   ),
                   Padding(
                     padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                     child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Row(
                                     children: [
                                       Text(car!.rating.toStringAsFixed(1), style: lightRoboto),
                                       Padding(
                          padding: const EdgeInsets.only(left: 2, right: 2),
                          child: Icon(Icons.star, color: onPrimary, size: 12),
                                       ),
                                       Text("(${car!.nbReviews.toString()} reviews)", style: lightRoboto,)
                                     ],
                                   ),
                          Text("${car!.dailyRate} \$ / Day", style: lightRoboto,),
                          
                       ],
                     ),
                    
        
                   ),
                   Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: HostPreviewContainer(listingOwner: listingOwner!),
                   ),
                   Padding(
                     padding: const EdgeInsets.only(left: 16, right: 16),
                     child: Divider(color: Color.fromARGB(255, 233, 233, 233),),
                   ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16, right: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                      Text(dateTimeToString(widget.dateTimeRange!.start), style: lightRoboto,),
                                      Text(dateTimeToString(widget.dateTimeRange!.end), style: lightRoboto,)
                                    ],),
                                    GestureDetector(
                                          onTap: (){},
                                          child: Text("CHANGE DATE", style: GoogleFonts.roboto(color: onPrimary, fontWeight: FontWeight.bold, fontSize: 10, decoration: TextDecoration.none),))
                              ],),
                            ),
                          Padding(
                     padding: const EdgeInsets.only(left: 16, right: 16),
                     child: Divider(color: Color.fromARGB(255, 233, 233, 233),),
                   ),
                   CarSpecs(transmission: car!.transmission, nbSeats: car!.nbSeats, fuel: car!.fuel),
                   Padding(
                     padding: const EdgeInsets.only(left: 16, right: 16),
                     child: Divider(color: Color.fromARGB(255, 233, 233, 233),),
                   ),
                   Padding(
                     padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
                     child: locationPreviewContainer(address: car!.address, latitude: car!.location.latitude, longitude: car!.location.longitude,),
                     
                   ),
                   Padding(
                     padding: const EdgeInsets.only(left: 16, right: 16),
                     child: Divider(color: Color.fromARGB(255, 233, 233, 233),),
                   ),
                   Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: Text("Reviews", style: boldRobotoBlack,),
                   ),
                  SizedBox(
                    height: 190,
                    child: ListView(
                      children: reviewWidgets,
                      scrollDirection: Axis.horizontal,
                    ),
                  ),
                  SizedBox(height: 80,)
                ],),
                Positioned(
                  top: 10,
                  left: 10,
                  child: CustomButtonWhite(iconSize: 20, icon:Icon(Icons.arrow_back), onPressed: (){print("buttonPressed");Navigator.pop(context);},)),
                  Positioned(top: 16, right: 16, child: FavoriteToggleButton(isFavorite: widget.isFavorite, size: 20, toggleFavoriteCallback: () async {
                    if (FirebaseAuth.instance.currentUser != null) {
                      toggleFavoritesCallback(currentUser, car!.docPath, widget.isFavorite);
                      widget.isFavorite = !widget.isFavorite;
                    } else {
                      showDialog(context: context, barrierDismissible: true, builder: (context) {
                                      return AlertDialog(
                                        title: Text('Sign In', style: robotoLargerBlack,),
                                        content: Text("You need to sign in to proceed."),
                                        actions: [
                                          TextButton(onPressed: (){Navigator.of(context).pop();}, child: Text("Cancel", style: robotoLargePrimary,),),
                                          TextButton(onPressed: (){
                                            widget.goToTab(4);
                                            Navigator.popUntil(context, (route) => route.isFirst);
                                          }, child: Text("Sign In", style: robotoLargePrimary)),
                                        ],
                                      );
                                    });
                    }
                    
                  },)),
                  Positioned(
                    bottom: 0,
        
                    child:  Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Total: ${car!.dailyRate * duration} \$", style: boldRoboto,),
                                Row(
                                  children: [
                                    Text(car!.rating.toStringAsFixed(1), style: lightRoboto),
                                               Padding(
                                                          padding: const EdgeInsets.only(left: 2, right: 2),
                                                          child: Icon(Icons.star, color: onPrimary, size: 12),
                                               ),
                                  ],
                                ),
                        
                            ],),
                            ElevatedButton(onPressed: (){
                              if (FirebaseAuth.instance.currentUser != null) {
                                  showDialog(context: context, barrierDismissible: true, builder: (context) {
                                      return AlertDialog(
                                        title: Text('Trip Confirmation', style: robotoLargerBlack,),
                                        content: Text("Confirm booking?"),
                                        actions: [
                                          TextButton(onPressed: (){Navigator.of(context).pop();}, child: Text("Cancel", style: robotoLargePrimary,),),
                                          TextButton(onPressed: (){
                                            Navigator.of(context).pop();
                                            showDialog(context: context, builder: (context) {
                                              return FutureBuilder(future: bookTrip(widget.listing!, Timestamp.fromMillisecondsSinceEpoch(widget.dateTimeRange!.start.millisecondsSinceEpoch), Timestamp.fromMillisecondsSinceEpoch(widget.dateTimeRange!.end.millisecondsSinceEpoch)), builder: (context, snapshot) {
                                                if (snapshot.connectionState == ConnectionState.done) {
                                                  Future.delayed(Duration.zero, () {
                                                  Navigator.popUntil(context, (route) => route.isFirst);
                                                           }).then((onValue){showCustomToast(context, "Your booking is confirmed!");}).then((onValue){});
                                                  
                                                  print("book success");
                                                  
                                                  
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
                                          }, child: Text("Book", style: robotoLargePrimary)),
                                        ],
                                      );
                                    });
                              }

                              else {
                                showDialog(context: context, barrierDismissible: true, builder: (context) {
                                      return AlertDialog(
                                        title: Text('Sign In', style: robotoLargerBlack,),
                                        content: Text("You need to sign in to proceed."),
                                        actions: [
                                          TextButton(onPressed: (){Navigator.of(context).pop();}, child: Text("Cancel", style: robotoLargePrimary,),),
                                          TextButton(onPressed: (){
                                            widget.goToTab(4);
                                            Navigator.popUntil(context, (route) => route.isFirst);
                                          }, child: Text("Sign In", style: robotoLargePrimary)),
                                        ],
                                      );
                                    });
                              }
                                  
                            }, child: Padding(
                                            padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                            child: Text("Reserve", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),),
                                          ), style: ElevatedButton.styleFrom(backgroundColor: onPrimary),),
                          ],
                        ),
                      ),
                    ))
              ],),
            ); 
          }
          else {
            return Stack(children: [
              Center(child: Text("this car is not currently available")),
              Positioned(
                  top: 10,
                  left: 10,
                  child: CustomButtonWhite(iconSize: 20, icon:Icon(Icons.arrow_back), onPressed: (){Navigator.pop(context);},)),]);
          }
          }
          else {
            return const CenteredCircularProgressIndicator();
          }
        }),
      ),
    );
  }
}

