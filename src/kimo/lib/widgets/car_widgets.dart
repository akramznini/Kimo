import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class CarPreviewContainer extends StatelessWidget {
  const CarPreviewContainer({
    super.key,
    required this.imagePath,
    required this.carName,
    required this.nbReviews,
    required this.rating,
    required this.height,
    required this.width
    });

  final String imagePath;
  final String carName;
  final int nbReviews;
  final double rating;
  final double height;
  final double width;
  @override
  Widget build(BuildContext context) {
    Image carImage = Image.asset(imagePath, height: height, width: width, fit: BoxFit.cover,);
    return IntrinsicWidth(
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0, top: 8, bottom: 12),
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: Color.fromARGB(255, 213, 213, 213), width: 0.5), borderRadius: BorderRadius.circular(22)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              carImage,
              CarInfoContainer(carName: carName, rating: rating, nbReviews: nbReviews,)
            ],),
          ),
        ),
      ),
    );
  }
}

class CarInfoContainer extends StatelessWidget {
  const CarInfoContainer({
    super.key,
    required this.carName,
    required this.rating,
    required this.nbReviews
  });

  final String carName;
  final double rating;
  final int nbReviews;
  
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextStyle lightRoboto = GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w300, color: Color.fromARGB(255, 84, 84, 84));
    return Padding(
      padding: const EdgeInsets.only(top:4, bottom:4, left: 8, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(carName, style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),),
          Row(
            children: [
              Text(rating.toString(), style: lightRoboto),
              Padding(
                padding: const EdgeInsets.only(left: 2, right: 2),
                child: Icon(Icons.star, color: theme.primaryColor, size: 12),
              ),
              Text("(${nbReviews.toString()} reviews)", style: lightRoboto,)
            ],
          )
        ],
      ),
    );
  }
}

