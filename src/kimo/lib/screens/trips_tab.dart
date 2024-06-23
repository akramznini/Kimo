import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget widget = TripsTab();

class TripsTab extends StatelessWidget {
  const TripsTab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text("Messages", style: GoogleFonts.roboto(color: Colors.black, fontSize:  16, fontWeight: FontWeight.bold)),
        ),
        
        Expanded(child: ListView(
          
        ),)
        
        ]);
  }
}