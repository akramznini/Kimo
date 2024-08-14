import 'dart:math';

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
import 'package:kimo/widgets/car_widgets.dart';
import 'package:kimo/widgets/widgets.dart';


class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({
    super.key,
    required this.city,
    required this.dateTimeRange,
    required this.goToTab
  });
  final void Function(int) goToTab;
  final String city;
  final DateTimeRange dateTimeRange;
  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {

  late Future<List<Listing>> fetchListings;
  var db = FirebaseFirestore.instance;

  Future<List<Listing>> fetchlistingsData() async {
      List<Listing> listings = [];
      try {
        var listingDocsSnapshot = await db.collection("listings").where("city", isEqualTo: widget.city).where("start_date", isLessThanOrEqualTo: Timestamp.fromDate(widget.dateTimeRange.start))
        .where("end_date", isGreaterThanOrEqualTo: Timestamp.fromDate(widget.dateTimeRange.end)).get();
        for (var doc in listingDocsSnapshot.docs) {
          listings.add(Listing.fromFirestore(doc));
        }
        return listings;
      }
      catch (err) {
        print(err.toString());
        return Future.error(err);
      }
      
    
    
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchListings = fetchlistingsData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(future: fetchListings, builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Listing> listings = snapshot.data!;
            Widget body;
            if (listings.isEmpty) {
              body = Center(child: Text("no results avaialable for current search"));
            }
            else {
              List<Widget> listingWidgets = [Center(child: TabTitle(title: "Available cars")), SizedBox(height: 20,)];
              for (var listing in listings) {
                listingWidgets.add(
                  Center(child: CarPreviewContainerWithPrice(onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                      return ListingDetails(goToTab: widget.goToTab, carDocPath: listing.carId, listing: listing, dateTimeRange: widget.dateTimeRange,);
                    }));
                  }, dailyRate: listing.dailyRate, imageUrl: listing.pictureUrl, brand: listing.brand, model: listing.model, nbReviews: listing.nbReviews, rating: listing.rating, height: 120, width: min(MediaQuery.of(context).size.width -50, 300)),)
                );
              }
              body = ListView(children: listingWidgets,);
        
            }
            return Scaffold(
              body: Stack(
                children: [
                  body,
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