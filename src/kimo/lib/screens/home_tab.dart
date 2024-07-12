import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kimo/widgets/car_widgets.dart';
import 'package:kimo/utils/theme_values.dart';
import 'package:kimo/utils/helper_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kimo/classes/listing.dart';
import 'package:geocoding/geocoding.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({
    super.key,
    required this.user,
    required this.geolocation
  });
  final User ?user;
  final Future<Position> geolocation;
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  
  bool firstBatchRetrieved = false;
  bool secondBatchRetrieved = false;
  bool dataRetrieved = false;
  bool blurred = false;
  double blurRadius = 0;
  double searchBoxPosition = 0;
  double searchBoxOpacity = 0;
  double arrowBackLeftPosition = 80;
  DateTimeRange dateRange = DateTimeRange(start: DateTime.now(), end: DateTime.now());
  List<Listing> nearbyListings = [];
  List<Listing> topPicksListings = [];
  
  Future<void> loadListingsData() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    
    // loads cars that are nearest to current location
    double perimeter = 1;
    int n = 0;
    double maxPerimeter = 16;
    
    widget.geolocation.then((position) async {
      while (n < 3){
        LatLngBounds bounds = calculateBounds(position.latitude, position.longitude, perimeter);
        await db.collection("listings").where('position_latitude', isLessThanOrEqualTo: bounds.highLat).where('position_latitude', isGreaterThanOrEqualTo: bounds.lowLat).where('position_longitude', isLessThanOrEqualTo: bounds.highLong).where('position_longitude', isGreaterThanOrEqualTo: bounds.lowLong).limit(3).get().then((querySnapshot) {
            n = querySnapshot.docs.length;
            if (n == 3 || perimeter == maxPerimeter) {
              for (var docSnapshot in querySnapshot.docs) {
                print("adding is executed");
                 nearbyListings.add(Listing.fromFirestore(docSnapshot));
              }
              setState(() {
                firstBatchRetrieved = true;
                dataRetrieved = firstBatchRetrieved && secondBatchRetrieved;
              });
            }
        n = querySnapshot.docs.length;
      });
      perimeter *= 2; 

      if (perimeter > maxPerimeter) {
        break;
      }
    }
      nearbyListings.sort((a, b) {
        double distanceFromA = sqrt(pow((a.positionLongitude - position.longitude), 2) + pow((a.positionLatitude - position.latitude), 2));
        double distanceFromB = sqrt(pow((b.positionLongitude - position.longitude), 2) + pow((b.positionLatitude - position.latitude), 2));
        
        return distanceFromA.compareTo(distanceFromB);
        });
      
      
      });

    await db.collection("listings").orderBy("rating").limit(3).get().then((querySnapshot){
        for (var docSnapshot in querySnapshot.docs){
          topPicksListings.add(Listing.fromFirestore(docSnapshot));
        }
    });
    
    try {
      
      final storageReference = FirebaseStorage.instance.ref();

      for (Listing listing in nearbyListings){
          listing.pictureUrl = await storageReference.child(listing.picturePath).getDownloadURL();
      }
      for (Listing listing in topPicksListings){
          listing.pictureUrl = await storageReference.child(listing.picturePath).getDownloadURL();
      }
      setState(() {
        secondBatchRetrieved = true;
        dataRetrieved = firstBatchRetrieved && secondBatchRetrieved;
      });
    } catch (e) {
      print('Error loading image: $e');
      // Handle error gracefully, e.g., show a placeholder image or error message
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadListingsData();
  }
  @override
  Widget build(BuildContext context) {
    Widget pageContent;
    if (dataRetrieved) {
      pageContent = FutureBuilder<Position>(
        future: widget.geolocation,
        builder: (context, snapshot) {
          double carPreviewHeight = 120;
          double carPreviewWidth = 160;
          Widget carsNearYou;
          Widget topPicks;
          if (snapshot.hasError){
             carsNearYou = Container(width: double.maxFinite, height: 200, child: Center(child: Text("Please enable location to see cars near by")));
          } else if (snapshot.hasData) {

            // populate CARS NEAR YOU containers

            List<CarPreviewContainer> carPreviewContainers = [];
            for (var listing in nearbyListings) {
              carPreviewContainers.add(CarPreviewContainer(imageUrl: listing.pictureUrl, brand: listing.brand, model: listing.model, nbReviews: listing.nbReviews, rating: listing.rating, height: carPreviewHeight, width: carPreviewWidth));
            }
            carsNearYou = SizedBox(
                          height: 185,
                          width: double.infinity,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: carPreviewContainers,
                          ),
                        );
          } else {
            return Center(child: Container(width: 50, height: 50 ,child: CircularProgressIndicator()));
          }

          // populate TOP PICKS containers
          List<CarPreviewContainer> carPreviewContainers = [];
            for (var listing in topPicksListings) {
              carPreviewContainers.add(CarPreviewContainer(imageUrl: listing.pictureUrl, brand: listing.brand, model: listing.model, nbReviews: listing.nbReviews, rating: listing.rating, height: carPreviewHeight, width: carPreviewWidth));
            }
            topPicks = SizedBox(
                          height: 185,
                          width: double.infinity,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: carPreviewContainers,
                          ),
                        );

        return Stack(
        children: [Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/images/kimo-logo.png', width: 150, height: 75, fit: BoxFit.cover,),
                  Row(
                    children: [
                      CustomButtonWhite(icon: Icon(Icons.search), onPressed: (){ setState(() {
                        blurred = true;
                        blurRadius = 10;
                      });
                      
                      Future.delayed(Duration(milliseconds: 30), (){setState(() {
                        searchBoxPosition = 80;
                        searchBoxOpacity = 1;
                        arrowBackLeftPosition = 30;
                      });});
                      
                      },),
                      CustomButtonWhite(icon: Icon(Icons.notifications_none), onPressed: (){})
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("CARS NEAR YOU", style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.w900),),
                        carsNearYou,
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("TOP PICKS FOR  YOU", style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.w900),),
                        topPicks
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        blurred ? Positioned.fill(child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurRadius,
            sigmaY: blurRadius
          ),
          child: Container(color: Colors.black.withOpacity(0),),)) : Container(),
        blurred ?  AnimatedPositioned(
          duration: Durations.long2,
          curve: Curves.easeInOut,
          child: AnimatedOpacity(duration: Durations.long2, opacity: searchBoxOpacity, 
          child: Container( decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: Colors.white),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("WHERE", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 10),), SizedBox(height: 8,), Container(width: 230, height: 40, child: TextField(textAlign: TextAlign.center,style: GoogleFonts.roboto(color: const Color.fromARGB(255, 94, 94, 94)) , decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none), fillColor: Color.fromARGB(255, 230, 230, 230), filled: true, hintText: "Add city"),))]),
                              SizedBox(height: 30),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start, 
                                children: [
                                  Text("WHEN", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 10)), 
                                  SizedBox(height: 8,), 
                                  GestureDetector(
                                    onTap: () async {
                                     final DateTimeRange? dateTimeRange = await showDateRangePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime(DateTime.now().year + 2));
                                     if (dateTimeRange != null) {setState(() {
                                       dateRange = dateTimeRange;
                                     });}
                                    },
                                    child: Container(
                                      width: 230, 
                                      height: 40, 
                                      decoration: BoxDecoration(
                                        color: Color.fromARGB(255, 230, 230, 230), 
                                        borderRadius: BorderRadius.circular(30)),
                                        child: Center(child: Text("${dateRange.start.weekday}/${dateRange.start.month}/${dateRange.start.year} - ${dateRange.end.weekday}/${dateRange.end.month}/${dateRange.end.year}", style: GoogleFonts.roboto(color: const Color.fromARGB(255, 94, 94, 94)),))))],),
                              SizedBox(height: 30),
                              ElevatedButton(onPressed: (){}, child: Padding(
                                padding: const EdgeInsets.only(left: 30, right: 30),
                                child: Text("FIND CARS", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),),
                              ), style: ElevatedButton.styleFrom(backgroundColor: onPrimary),)
                            ],),
                          ),)),
          top: searchBoxPosition,
          left: 15,
          right: 15,
          ) : Container(),
        blurred ?  AnimatedPositioned(
          duration: Durations.long2,
          curve: Curves.easeInOut,
          child: AnimatedOpacity(duration: Durations.long2, opacity: searchBoxOpacity, child: CustomButtonWhite(icon: Icon(Icons.arrow_back), onPressed: (){
            setState(() {
            arrowBackLeftPosition = 80;
            searchBoxOpacity = 0;
            searchBoxPosition = 0;
        
          });
          Future.delayed(Durations.long2, (){
            setState(() {
              blurRadius = 0;
              blurred = false;
            });
          });
          },)),
          top: 20,
          left: arrowBackLeftPosition,
          ) : Container(),
            ]);
          
        }
        
      );
    }
    else {
      pageContent = Center(child: Container(width: 50, height: 50 ,child: CircularProgressIndicator()));
    }
    

    return pageContent;
  }

  
}

class CustomButtonWhite extends StatelessWidget {
  const CustomButtonWhite({
    super.key,
    required this.icon,
    required this.onPressed,
  });
  final Icon icon;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: greySelected, width: 0.5)),
        child: IconButton(
        onPressed: onPressed,
        icon: icon,
        iconSize: 24,
        color: Colors.black, // Icon color
        splashRadius: 24, // Increase the splash radius to make the button easier to tap 
        padding: EdgeInsets.all(10), // Remove default padding
              ),
      ),
    );
  }
}



