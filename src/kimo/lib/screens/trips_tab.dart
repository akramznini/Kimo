import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kimo/widgets/car_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TripsTab extends StatelessWidget {
  const TripsTab({
    super.key,
    required this.user
  });
  final User ?user;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text("Trips", style: GoogleFonts.roboto(color: Colors.black, fontSize:  16, fontWeight: FontWeight.bold)),
        ),
        
        Expanded(child: ListView(
          children: [Center(child: TripPreviewContainer(carName: "Honda Civic", imagePath: "assets/images/car-volkswagen.jpg", location: "9705 Rue Basile-Routhier", checkInDate: DateTime.parse('1969-07-20 20:18:04Z'), checkOutDate: DateTime.parse('1969-07-20 20:18:04Z'), height: 120, width: 260,))
      ]),)
        
        ]);
  }
}