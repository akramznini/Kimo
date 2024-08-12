import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kimo/screens/listing_details.dart';
import 'package:kimo/screens/search_results_page.dart';
import 'package:kimo/widgets/buttons.dart';
import 'package:kimo/widgets/car_widgets.dart';
import 'package:kimo/utils/theme_values.dart';
import 'package:kimo/utils/helper_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kimo/classes/listing.dart';
import 'package:geocoding/geocoding.dart';
import 'package:kimo/widgets/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
class HomeTab extends StatefulWidget {
  const HomeTab({
    super.key,
    required this.user,
    required this.geolocation,
    this.searchOnOpen = false
  });
  final bool searchOnOpen;
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
  late DateTimeRange dateRange;
  List<Listing> nearbyListings = [];
  List<Listing> topPicksListings = [];
  List wishlist = [];
  
  Future<void> loadListingsData() async {
    DateTime dateTimeNow = DateTime.now().toUtc();
    DateTime startDate = DateTime(dateTimeNow.year, dateTimeNow.month, dateTimeNow.day, 0, 0, 0);
    dateRange = DateTimeRange(start: startDate.add(Duration(days: 1)), end: startDate.add(Duration(days: 2)));

    FirebaseFirestore db = FirebaseFirestore.instance;
    // loads cars that are nearest to current location
    double perimeter = 1;
    int n = 0;
    double maxPerimeter = 16;
    List<Future<void>> futures = [];
    if (widget.user != null) {
        var userDoc = await db.collection("users").where("UID", isEqualTo: widget.user!.uid).get();
        wishlist = userDoc.docs.first.data()["wishlist"] as List;
      }
    widget.geolocation.then((position) async {
      


      while (n < 3){
        LatLngBounds bounds = calculateBounds(position.latitude, position.longitude, perimeter);
        await db.collection("listings").where("start_date", isLessThanOrEqualTo: Timestamp.fromDate(dateRange.start))
        .where("end_date", isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.end))
        .where('position_latitude', isLessThanOrEqualTo: bounds.highLat)
        .where('position_latitude', isGreaterThanOrEqualTo: bounds.lowLat)
        .where('position_longitude', isLessThanOrEqualTo: bounds.highLong)
        .where('position_longitude', isGreaterThanOrEqualTo: bounds.lowLong)
        .limit(3).get().then((querySnapshot) async {
            n = querySnapshot.docs.length;
            if (n == 3 || perimeter == maxPerimeter) {
              for (var docSnapshot in querySnapshot.docs) {
                Listing listing = Listing.fromFirestore(docSnapshot);
                 nearbyListings.add(listing);
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

    await db.collection("listings").where("start_date", isLessThanOrEqualTo: Timestamp.fromDate(dateRange.start))
    .where("end_date", isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.end))
    .orderBy("rating", descending: true).limit(3).get().then((querySnapshot){
        for (var docSnapshot in querySnapshot.docs){
          Listing listing = Listing.fromFirestore(docSnapshot);
          topPicksListings.add(listing);
        }
    });
    
    try {
      
      final storageReference = FirebaseStorage.instance.ref();
      

// First loop for nearbyListings

// Second loop for topPicksListings

// Wait for all futures to complete
await Future.wait(futures).then((snapshot){setState(() {
  secondBatchRetrieved = true;
  dataRetrieved = firstBatchRetrieved && secondBatchRetrieved;
});});

// After both loops complete

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
    if (widget.searchOnOpen) {
      blurred = true;
      blurRadius = 10;
    }
  }



  @override
  Widget build(BuildContext context) {
    Widget pageContent;
    print(dataRetrieved);

    final TextEditingController _cityTextcontroller = TextEditingController();
    if (dataRetrieved) {
      print("inside future");
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
              
              // TODO: duplicate attributes with listing
              carPreviewContainers.add(CarPreviewContainer(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context){return ListingDetails(dateTimeRange: dateRange, carDocPath: listing.carId);}));}, imageUrl: listing.pictureUrl, brand: listing.brand, model: listing.model, nbReviews: listing.nbReviews, rating: listing.rating, height: carPreviewHeight, width: carPreviewWidth));
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
            return const CenteredCircularProgressIndicator();
          }

          // populate TOP PICKS containers
          List<CarPreviewContainer> carPreviewContainers = [];
            for (var listing in topPicksListings) {
              
              carPreviewContainers.add(CarPreviewContainer(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context){return ListingDetails(dateTimeRange: dateRange, carDocPath: listing.carId);}));}, imageUrl: listing.pictureUrl, brand: listing.brand, model: listing.model, nbReviews: listing.nbReviews, rating: listing.rating, height: carPreviewHeight, width: carPreviewWidth));
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
                      CustomButtonWhite(iconSize: 24, icon: Icon(Icons.search), onPressed: (){ setState(() {
                        blurred = true;
                        blurRadius = 10;
                      });
                      
                      Future.delayed(Duration(milliseconds: 30), (){setState(() {
                        searchBoxPosition = 80;
                        searchBoxOpacity = 1;
                        arrowBackLeftPosition = 30;
                      });});
                      
                      },),
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start, 
                                children: [
                                  Text("WHEN", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 10)), 
                                  
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
                                        child: Center(child: Text("${dateRange.start.day}/${dateRange.start.month}/${dateRange.start.year} - ${dateRange.end.day}/${dateRange.end.month}/${dateRange.end.year}", style: GoogleFonts.roboto(color: const Color.fromARGB(255, 94, 94, 94)),))))],),
                              SizedBox(height: 8,), 
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("WHERE", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 10),), SizedBox(height: 8,), Container(width: 230, height: 40, child: TextField(controller: _cityTextcontroller, textAlign: TextAlign.center,style: GoogleFonts.roboto(color: const Color.fromARGB(255, 94, 94, 94)) , decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none), fillColor: Color.fromARGB(255, 230, 230, 230), filled: true, hintText: "Add city"),))]),
                              SizedBox(height: 30),
                              SizedBox(height: 30),
                              ElevatedButton(onPressed: () async {
                                if (_cityTextcontroller.text.toLowerCase() == "montreal") {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                    return SearchResultsPage(city: _cityTextcontroller.text, dateTimeRange: dateRange);
                                  }));
                                }
                                print(_cityTextcontroller.text);
                                
                              }, child: Padding(
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
          child: AnimatedOpacity(duration: Durations.long2, opacity: searchBoxOpacity, child: CustomButtonWhite(iconSize: 24, icon: Icon(Icons.arrow_back), onPressed: (){
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
      pageContent = const CenteredCircularProgressIndicator();
    }
    

    return pageContent;
  }

  
}

class AutocompleteWidget extends StatelessWidget {
  final List<String> cities = ["Montreal"];

  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = TextEditingController();

    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          return cities.where((String option) {
            return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
          }).toList();
        },
        onSelected: (String selection) {
          _controller.text = selection;
        },
        fieldViewBuilder: (BuildContext context, TextEditingController controller, FocusNode focusNode, VoidCallback onFieldSubmitted) {
          _controller = controller;
          return TextField(
            controller: controller,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(color: const Color.fromARGB(255, 94, 94, 94)),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              fillColor: Color.fromARGB(255, 230, 230, 230),
              filled: true,
              hintText: "Add city",
            ),
          );
        },
        optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              child: Container(
                color: Colors.white,
                child: SizedBox(
                  height: 200.0,
                  child: ListView(
                    children: options.map((String option) => ListTile(
                      title: Text(option),
                      onTap: () {
                        onSelected(option);
                      },
                    )).toList(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}



