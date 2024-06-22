import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomNavigationDestination extends StatelessWidget {
  final bool selected;
  final String svgPath;
  final String label;
  final String svgPathSelected;
  const CustomNavigationDestination({
    super.key,
    required this.selected,
    required this.svgPath,
    required this.label,
    required this.svgPathSelected
  });

  @override
  Widget build(BuildContext context) {
    final Color greySelected = Color.fromARGB(255, 228, 228, 228);
    return Container(child: Padding(
      padding: const EdgeInsets.only(top: 6.0, bottom: 6.0, left: 8, right: 8),
      child: Column(children: <Widget>[SvgPicture.asset(selected ? svgPathSelected : svgPath, height: 35, width: 35,), Text(label, style: GoogleFonts.roboto(fontSize: 8, fontWeight: FontWeight.bold)),]),
    ), decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: selected? greySelected : null),);
  }
}