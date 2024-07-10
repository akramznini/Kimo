import 'package:flutter/material.dart';
import 'package:kimo/widgets/car_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kimo/utils/theme_values.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistTab extends StatelessWidget {
  const WishlistTab({
    super.key,
    required this.user
  });
  final User ?user;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 8),
                            child: Text("Wishlist", style: GoogleFonts.roboto(color: Colors.black, fontSize:  16, fontWeight: FontWeight.bold)),
                          ),
                      Expanded(
                        child: ListView(
                          
                          children: [
                            
                            /*Center(
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                CarPreviewContainer(carName: "Lamborghini Huracan", imageData: "assets/images/car-volkswagen.jpg", nbReviews: 120, rating: 4.9, height: 120, width: 260,),
                                Positioned(top: 16, right: 16, child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: IconButton(icon: Icon(Icons.favorite, color: onPrimary,), iconSize: 20 ,onPressed: (){},)))
                              ],),
                            ),
                            Center(
                              child: Stack(
                                      
                                alignment: Alignment.topRight,
                                children: [
                                CarPreviewContainer(carName: "Lamborghini Huracan", imageData: "assets/images/car-volkswagen.jpg", nbReviews: 120, rating: 4.9, height: 120, width: 260,),
                                Positioned(top: 16, right: 16, child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: IconButton(icon: Icon(Icons.favorite, color: onPrimary,), iconSize: 20 ,onPressed: (){},)))
                              ],),
                            ),
                            Center(
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                CarPreviewContainer(carName: "Lamborghini Huracan", imageData: "assets/images/car-volkswagen.jpg", nbReviews: 120, rating: 4.9, height: 120, width: 260,),
                                Positioned(top: 16, right: 16, child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: IconButton(icon: Icon(Icons.favorite, color: onPrimary,), iconSize: 20 ,onPressed: (){},)))
                              ],),
                            )*/
                          ],
                        ),
                      ),
                    ],),
    );
  }
}