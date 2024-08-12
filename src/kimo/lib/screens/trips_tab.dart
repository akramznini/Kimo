import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kimo/classes/car.dart';
import 'package:kimo/classes/trip.dart';
import 'package:kimo/screens/trip_details.dart';
import 'package:kimo/utils/theme_values.dart';
import 'package:kimo/widgets/car_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kimo/widgets/widgets.dart';

class TripsTab extends StatefulWidget {
  const TripsTab({
    super.key,
    required this.user,
    required this.goToTab
  });
  final void Function(int) goToTab;
  final User ?user;

  @override
  State<TripsTab> createState() => _TripsTabState();
}

class _TripsTabState extends State<TripsTab> {
  late Future<List<Trip>> fetchTrips;
  Future<List<Trip>> fetchTripsData() async {
    if (widget.user != null){
    try {
    var db = FirebaseFirestore.instance;
    var userDocQuerySnapshot = await db.collection("users").where("UID", isEqualTo: widget.user!.uid).get();
    var userDocId = userDocQuerySnapshot.docs.first.id;

    var tripDocsQuerySnapshot = await db.collection("trips").where("guest", isEqualTo: userDocId).get();
    List<Trip> trips = [];

    for (var tripDoc in tripDocsQuerySnapshot.docs) {
      trips.add(Trip.fromFirestore(tripDoc));
    }

    return trips;
    }
    catch (err) {
      return Future.error(err.toString());
    }

    }
    else {return Future.error("user is not signed");}

  }




  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTrips = fetchTripsData();
  }



  @override
  Widget build(BuildContext context) {
    return FutureBuilder <List<Trip>>(
      future: fetchTrips,
      builder: (context, snapshot) {
        if (snapshot.hasData) {

          List<Trip> trips = snapshot.data!;
          List<Widget> currentTripsWidgets = [];
          List<Widget> previousTripsWidgets = [];
          List<Widget> cancelledTripsWidgets = [];
          for (var trip in trips) {
            var tripWidgets;
            if (trip.isCancelled) {
              tripWidgets = cancelledTripsWidgets;
            }
            else {
              if (trip.endDate.millisecondsSinceEpoch < Timestamp.now().millisecondsSinceEpoch){
                // previous trip
                tripWidgets = previousTripsWidgets;
              }
              else {
                tripWidgets = currentTripsWidgets;
              }
            }
            tripWidgets.add(Center(child: GestureDetector(onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context){return TripDetails(trip: trip,);})).then((value) {setState(() {
              fetchTrips = fetchTripsData();
            });});},
            child: TripPreviewContainer(imagePath: trip.pictureUrl, carBrand: trip.carBrand, carModel: trip.carModel, checkInDate: DateTime.fromMillisecondsSinceEpoch(trip.startDate.millisecondsSinceEpoch), checkOutDate: DateTime.fromMillisecondsSinceEpoch(trip.endDate.millisecondsSinceEpoch), address: trip.address, height: 60, width: 80))));
          }
          Widget content;
          List<Widget> widgets = [];
          if (currentTripsWidgets.isEmpty) {
            widgets.add(Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(width: 1, color: greySelected)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  SvgPicture.asset("assets/icons/car-icon.svg", width: 60, height: 60,),
                  Text("Book your next trip!", style: robotoLargerBlack,),
                  Text("Start your adventure by booking the perfect car for your trip.", style: lightRoboto, textAlign: TextAlign.center,),
                  SizedBox(height: 20,),
                  ElevatedButton(onPressed: (){widget.goToTab(0);}, child: Container(height: 20, width: 120, child: Center(child: Text("FIND CARS", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),))), style: ElevatedButton.styleFrom(backgroundColor: onPrimary),),
                  SizedBox(height: 20,),
                ],),
              ),
            ),
          ));
          }
          else {
            widgets.addAll(currentTripsWidgets);
          }
          if (previousTripsWidgets.isNotEmpty) {
            widgets.add(SizedBox(height: 20,));
            widgets.add(Text("Previous trips", style: robotoLargerBlack,));
            widgets.addAll(previousTripsWidgets);
          }
          if (cancelledTripsWidgets.isNotEmpty) {
            widgets.add(SizedBox(height: 20,));
            widgets.add(Text("Cancelled trips", style: robotoLargerBlack,));
            widgets.addAll(cancelledTripsWidgets);
          }
          
          content = Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(children: widgets,),
          );
          return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text("Trips", style: GoogleFonts.roboto(color: Colors.black, fontSize:  16, fontWeight: FontWeight.bold)),
          ),
          
          Expanded(child: content,)
          
          ]);
        }
        else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        else {
          return CenteredCircularProgressIndicator();
        }
      },
    );
  }
}