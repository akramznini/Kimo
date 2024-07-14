import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kimo/classes/car.dart';
import 'package:kimo/classes/listing.dart';
import 'package:kimo/classes/listing_owner.dart';
import 'package:kimo/screens/home_tab.dart';
import 'package:kimo/utils/helper_functions.dart';
import 'package:kimo/utils/theme_values.dart';
import 'package:kimo/widgets/buttons.dart';
import 'package:kimo/widgets/car_widgets.dart';

class ListingDetails extends StatefulWidget {
  const ListingDetails({
    super.key,
    required this.carDocPath,
    required this.dateTimeRange
  });
  final DateTimeRange dateTimeRange;
  final String carDocPath;

  @override
  State<ListingDetails> createState() => _ListingDetailsState();
}

class _ListingDetailsState extends State<ListingDetails> {
  @override
  Widget build(BuildContext context) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    Car ?car;
    ListingOwner ?listingOwner;
    Future<void> fetchData() async {
      try {
        DocumentSnapshot carDocResponse = await db.doc(widget.carDocPath).get();
        if (carDocResponse.exists){
          car = Car.fromFirestore(carDocResponse);
          DocumentSnapshot listingOwnerDoc = await db.collection("users").doc(car!.ownerDocId).get();
          listingOwner = ListingOwner.fromFirestore(listingOwnerDoc);
        }
        }
      catch (e) {
        return Future.error("couldn't fetch data");
      }

    }
    
    //Future<DocumentSnapshot<Map<String, dynamic>>> future = db.doc(carDocPath).get();


    return FutureBuilder(future: fetchData(), builder: (context, snapshot){
      if (snapshot.hasError){
        return Center(child: Text("An error occured while loading the page"));
      }
      else if (car != null){
        return Container(
          color: Colors.white,
          child: Stack(children: [
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
                                   Text(car!.rating.toString(), style: lightRoboto),
                                   Padding(
                      padding: const EdgeInsets.only(left: 2, right: 2),
                      child: Icon(Icons.star, color: onPrimary, size: 12),
                                   ),
                                   Text("(${car!.nbReviews.toString()} reviews)", style: lightRoboto,)
                                 ],
                               ),
                      Text("${car!.dailyRate} MAD / Day", style: lightRoboto,),
                      
                   ],
                 ),
                

               ),
               Padding(
                 padding: const EdgeInsets.all(8.0),
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
                              Text("Hosted by ", style: boldRoboto,),
                              Text(listingOwner!.firstName, style: lightRoboto)
                            ],),
                            Text("${listingOwner!.nbTrips} trips given", style: lightRobotoSmall)
                          ],),
                        )
                        
                        ],),
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
                                  Text(dateTimeToString(widget.dateTimeRange.start), style: lightRoboto,),
                                  Text(dateTimeToString(widget.dateTimeRange.end), style: lightRoboto,)
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
               CarSpecs(transmission: car!.transmission, nbSeats: car!.nbSeats, fuel: car!.fuel)
            ],),
            Positioned(
              top: 10,
              left: 10,
              child: CustomButtonWhite(iconSize: 20, icon:Icon(Icons.arrow_back), onPressed: (){Navigator.pop(context);},)),
              Positioned(top: 16, right: 16, child: FavoriteToggleButton(isFavorite: false, carDocPath: widget.carDocPath,))
          ],),
        ); 
      }
      else {
        return Center(child: Container(width: 50, height: 50 ,child: CircularProgressIndicator()));
      }
    });
  }
}