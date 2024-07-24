import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kimo/classes/car.dart';
import 'package:kimo/screens/listing_details.dart';
import 'package:kimo/widgets/buttons.dart';
import 'package:kimo/widgets/car_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kimo/utils/theme_values.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kimo/widgets/widgets.dart';

class WishlistTab extends StatefulWidget {
  const WishlistTab({
    super.key,
    required this.user
  });
  final User ?user;

  @override
  State<WishlistTab> createState() => _WishlistTabState();
}

class _WishlistTabState extends State<WishlistTab> {

  late Future<List<Car>> fetchCars;

  Future<List<Car>> fetchFavoriteCars() async {
    if (widget.user != null){
    try {
    var db = FirebaseFirestore.instance;
    var userDoc = await db.collection("users").where("UID", isEqualTo: widget.user!.uid).get();
    var wishlist = userDoc.docs.first.data()["wishlist"] as List;
    print(wishlist.toString());
    List<Car> cars = [];
    for (var carDocPath in wishlist){
      print(carDocPath);
      Car car = Car.fromFirestore(await db.doc(carDocPath).get());
      cars.add(car);
    }
    return cars;
    }
    catch (err) {
      return Future.error("error fetching data");
    }

    }
    else {return Future.error("user is not signed");}

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchCars = fetchFavoriteCars();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Car>>(future: fetchCars, builder: (context, snapshot){
      
      if (snapshot.hasData){
        List<Widget> carWidgets = [];
        for (var car in snapshot.data!){
          carWidgets.add(Center(
            child: WishlistCarPreviewContainer(id: 1, onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context){return ListingDetails(carDocPath: car.docPath,);})).then((value) {setState(() {
              fetchCars = fetchFavoriteCars();
            });});}, onFavoritePressed: () async {
              await toggleFavoritesCallback(widget.user, car.docPath, true);
              setState(() {
                fetchCars = fetchFavoriteCars();
              });
              }, imageUrl: car.pictures[0], brand: car.brand, model: car.model, nbReviews: car.nbReviews, rating: car.rating, height: 120, width: min(MediaQuery.of(context).size.width -50, 300)),
          ));
      }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          TabTitle(title: "Wishlist"),

          Expanded(
            child: ListView(children: carWidgets,)),

        ],);
      }
      else if (snapshot.hasError){
        return Text(snapshot.error.toString());
      }
      else {
        return CenteredCircularProgressIndicator();
      }
    });
  }
}