import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kimo/main.dart';
import 'package:kimo/widgets/car_widgets.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
  });

  

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/images/kimo-logo.png', width: 130, height: 65, fit: BoxFit.cover,),
            Row(
              children: [
                CustomButtonWhite(icon: Icon(Icons.search), onPressed: (){},),
                CustomButtonWhite(icon: Icon(Icons.notifications_none), onPressed: (){})
              ],
            ),
          ],
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
                    SizedBox(
                      height: 185,
                      width: double.infinity,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          CarPreviewContainer(imagePath: "assets/images/car-volkswagen.jpg", carName: "Vlokswagen Beetle ", nbReviews: 122, rating: 4.6,),
                          CarPreviewContainer(imagePath: "assets/images/car-volkswagen.jpg", carName: "Vlokswagen Beetle ", nbReviews: 122, rating: 4.6,),
                          CarPreviewContainer(imagePath: "assets/images/car-volkswagen.jpg", carName: "Vlokswagen Beetle ", nbReviews: 122, rating: 4.6,),
                        ],
                      ),
                    ),
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
                          CarPreviewContainer(imagePath: "assets/images/car-volkswagen.jpg", carName: "Vlokswagen Beetle ", nbReviews: 122, rating: 4.6,),
                          CarPreviewContainer(imagePath: "assets/images/car-volkswagen.jpg", carName: "Vlokswagen Beetle ", nbReviews: 122, rating: 4.6,),
                          CarPreviewContainer(imagePath: "assets/images/car-volkswagen.jpg", carName: "Vlokswagen Beetle ", nbReviews: 122, rating: 4.6,),
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
    );
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
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: MyApp.greySelected, width: 0.5)),
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



