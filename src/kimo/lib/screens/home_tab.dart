import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kimo/widgets/car_widgets.dart';
import 'package:kimo/utils/theme_values.dart';
import 'package:kimo/utils/helper_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
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
  
  bool dataRetrieved = true;
  late String imgUrl;
  bool blurred = false;
  double blurRadius = 0;
  double searchBoxPosition = 0;
  double searchBoxOpacity = 0;
  double arrowBackLeftPosition = 80;
  DateTimeRange dateRange = DateTimeRange(start: DateTime.now(), end: DateTime.now());
  
  
  Future<void> loadImage() async {
    try {
      final storageReference = FirebaseStorage.instance.ref();
      String imgUrl1 = await storageReference.child("car_pictures/car-volkswagen.jpg").getDownloadURL();

      setState(() {
        imgUrl = imgUrl1;
        dataRetrieved = true;
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
    loadImage();
  }
  @override
  Widget build(BuildContext context) {
    Widget pageContent;
    if (dataRetrieved) {
      pageContent = FutureBuilder<Position>(
        future: widget.geolocation,
        builder: (context, snapshot) {
          Widget carsNearYou;
          if (snapshot.hasError){
             carsNearYou = Text("Please enable location to see cars near by");
          } else if (snapshot.hasData) {
            carsNearYou = SizedBox(
                          height: 185,
                          width: double.infinity,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              Text("device location is: ${snapshot.data!.longitude}, ${snapshot.data!.latitude}"),
                              CarPreviewContainer(imageUrl: "https://hips.hearstapps.com/hmg-prod/images/2019-honda-civic-sedan-1558453497.jpg", carName: "Vlokswagen Beetle ", nbReviews: 122, rating: 4.6, height: 120, width: 160,),
                              CarPreviewContainer(imageUrl: "https://firebasestorage.googleapis.com/v0/b/kimo-3f95e.appspot.com/o/car_pictures%2Fcar-volkswagen.jpg?alt=media&token=7e2e6961-338b-4121-89a6-6e34c3e02032", carName: "Vlokswagen Beetle ", nbReviews: 122, rating: 4.6, height: 120, width: 160,),
                              CarPreviewContainer(imageUrl: "https://firebasestorage.googleapis.com/v0/b/kimo-3f95e.appspot.com/o/car_pictures%2Fcar-volkswagen.jpg?alt=media&token=7e2e6961-338b-4121-89a6-6e34c3e02032", carName: "Vlokswagen Beetle ", nbReviews: 122, rating: 4.6, height: 120, width: 160,),
                            ],
                          ),
                        );
          } else {
            return Center(child: Container(width: 50, height: 50 ,child: CircularProgressIndicator()));
          }
          return Stack(
        children: [Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/images/kimo-logo.png', width: 100, height: 50, fit: BoxFit.cover,),
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
                        SizedBox(
                          height: 185,
                          width: double.infinity,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              CarPreviewContainer(imageUrl: "https://firebasestorage.googleapis.com/v0/b/kimo-3f95e.appspot.com/o/car_pictures%2Fcar2.jpg?alt=media&token=aaef9981-1f94-4dc9-b735-c269fb20681a", carName: "Vlokswagen Beetle ", nbReviews: 122, rating: 4.6, height: 120, width: 160,),
                              CarPreviewContainer(imageUrl: "https://firebasestorage.googleapis.com/v0/b/kimo-3f95e.appspot.com/o/car_pictures%2Fcar-volkswagen.jpg?alt=media&token=7e2e6961-338b-4121-89a6-6e34c3e02032", carName: "Vlokswagen Beetle ", nbReviews: 122, rating: 4.6, height: 120, width: 160,),
                              CarPreviewContainer(imageUrl: "https://firebasestorage.googleapis.com/v0/b/kimo-3f95e.appspot.com/o/car_pictures%2Fcar-volkswagen.jpg?alt=media&token=7e2e6961-338b-4121-89a6-6e34c3e02032", carName: "Vlokswagen Beetle ", nbReviews: 122, rating: 4.6, height: 120, width: 160,),
                            ],
                          ),
                        ),
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



