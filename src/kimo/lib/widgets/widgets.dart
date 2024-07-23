import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CenteredCircularProgressIndicator extends StatelessWidget {
  const CenteredCircularProgressIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(child: Container(width: 50, height: 50 ,child: CircularProgressIndicator()));
  }
}

class TabTitle extends StatelessWidget {
  const TabTitle({
    super.key,
    required this.title
  });
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(title, style: GoogleFonts.roboto(color: Colors.black, fontSize:  16, fontWeight: FontWeight.bold)),
            );
  }
}
