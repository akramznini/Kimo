import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kimo/classes/car.dart';
import 'package:kimo/classes/trip.dart';
import 'package:kimo/screens/trip_details.dart';
import 'package:kimo/widgets/car_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kimo/widgets/widgets.dart';

class TripsTab extends StatefulWidget {
  const TripsTab({
    super.key,
    required this.user
  });
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
          List<Widget> tripWidgets = [];
          for (var trip in trips) {
            tripWidgets.add(Center(child: GestureDetector(onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context){return TripDetails(trip: trip,);})).then((value) {setState(() {
              fetchTrips = fetchTripsData();
            });});},
            child: TripPreviewContainer(imagePath: trip.pictureUrl, carBrand: trip.carBrand, carModel: trip.carModel, checkInDate: DateTime.fromMillisecondsSinceEpoch(trip.startDate.millisecondsSinceEpoch), checkOutDate: DateTime.fromMillisecondsSinceEpoch(trip.endDate.millisecondsSinceEpoch), address: trip.address, height: 120, width: 260))));
          }

          return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text("Trips", style: GoogleFonts.roboto(color: Colors.black, fontSize:  16, fontWeight: FontWeight.bold)),
          ),
          
          Expanded(child: ListView(
            children: tripWidgets),)
          
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