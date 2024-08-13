import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kimo/classes/address.dart';
import 'package:kimo/classes/listing.dart';
import 'package:kimo/screens/listing_details.dart';
import 'package:kimo/utils/theme_values.dart';
import 'package:kimo/widgets/buttons.dart';



class WishlistCarPreviewContainer extends StatelessWidget {
  const WishlistCarPreviewContainer({
    super.key,
    required this.onPressed,
    required this.onFavoritePressed,
    required this.imageUrl,
    required this.brand,
    required this.model,
    required this.nbReviews,
    required this.rating,
    required this.height,
    required this.width,
    required this.id
    });
  final VoidCallback onPressed;
  final VoidCallback onFavoritePressed;
  final String imageUrl;
  final String brand;
  final String model;
  final int nbReviews;
  final double rating;
  final double height;
  final double width;
  final int id;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CarPreviewContainer(onPressed: onPressed, imageUrl: imageUrl, brand: brand, model: model, nbReviews: nbReviews, rating: rating, height: height, width: width),
        Positioned(
          top: 15,
          left: width - 35,
          child: FavoriteToggleButton(isFavorite: true, size: 15, toggleFavoriteCallback: onFavoritePressed,))
      ],
    );
  }
}




class CarPreviewContainer extends StatelessWidget {
  const CarPreviewContainer({
    super.key,
    required this.onPressed,
    required this.imageUrl,
    required this.brand,
    required this.model,
    required this.nbReviews,
    required this.rating,
    required this.height,
    required this.width,
    
    });
  final VoidCallback onPressed;
  final String imageUrl;
  final String brand;
  final String model;
  final int nbReviews;
  final double rating;
  final double height;
  final double width;
  @override
  Widget build(BuildContext context) {
    Image carImage = Image.network(imageUrl, height: height, width: width, fit: BoxFit.cover,);
    return GestureDetector(
      onTap: onPressed,
      child: IntrinsicWidth(
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0, top: 8, bottom: 12),
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: Color.fromARGB(255, 213, 213, 213), width: 0.5), borderRadius: BorderRadius.circular(22)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                carImage,
                CarInfoContainer(brand: brand, model: model, rating: rating, nbReviews: nbReviews,)
              ],),
            ),
          ),
        ),
      ),
    );
  }
}

class CarPreviewContainerWithPrice extends StatelessWidget {
  const CarPreviewContainerWithPrice({
    super.key,
    required this.onPressed,
    required this.imageUrl,
    required this.brand,
    required this.model,
    required this.nbReviews,
    required this.rating,
    required this.height,
    required this.width,
    required this.dailyRate
    });
  final VoidCallback onPressed;
  final String imageUrl;
  final String brand;
  final String model;
  final int nbReviews;
  final double rating;
  final double height;
  final double width;
  final int dailyRate;
  @override
  Widget build(BuildContext context) {
    Image carImage = Image.network(imageUrl, height: height, width: width, fit: BoxFit.cover,);
    return GestureDetector(
      onTap: onPressed,
      child: IntrinsicWidth(
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0, top: 8, bottom: 12),
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: Color.fromARGB(255, 213, 213, 213), width: 0.5), borderRadius: BorderRadius.circular(22)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                carImage,
                CarInfoContainerWithPrice(brand: brand, model: model, rating: rating, nbReviews: nbReviews, dailyRate: dailyRate,)
              ],),
            ),
          ),
        ),
      ),
    );
  }
}

class CarInfoContainer extends StatelessWidget {
  const CarInfoContainer({
    super.key,
    required this.brand,
    required this.model,
    required this.rating,
    required this.nbReviews
  });

  final String brand;
  final String model;
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
          Text("${brand} ${model}", style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),),
          Row(
            children: [
              Text(rating.toStringAsFixed(1), style: lightRoboto),
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

class CarInfoContainerWithPrice extends StatelessWidget {
  const CarInfoContainerWithPrice({
    super.key,
    required this.brand,
    required this.model,
    required this.rating,
    required this.nbReviews,
    required this.dailyRate
  });

  final String brand;
  final String model;
  final double rating;
  final int nbReviews;
  final int dailyRate;
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextStyle lightRoboto = GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w300, color: Color.fromARGB(255, 84, 84, 84));
    return Padding(
      padding: const EdgeInsets.only(top:4, bottom:4, left: 8, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${brand} ${model}", style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),),
          Padding(
            padding: const EdgeInsets.only( right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(rating.toStringAsFixed(1), style: lightRoboto),
                    Padding(
                      padding: const EdgeInsets.only(left: 2, right: 2),
                      child: Icon(Icons.star, color: theme.primaryColor, size: 12),
                    ),
                    Text("(${nbReviews.toString()} reviews)", style: lightRoboto,)
                  ],
                ),
                Text("${dailyRate} \$ / Day", style: boldRobotoBlack)
              ],
            ),
          )
        ],
      ),
    );
  }
}

class TripPreviewContainerLarge extends StatelessWidget {
  const TripPreviewContainerLarge({
    super.key,
    required this.imagePath,
    required this.carBrand,
    required this.carModel,
    required this.checkInDate,
    required this.checkOutDate,
    required this.address,
    required this.height,
    required this.width
    });

  final String imagePath;
  final String carBrand;
  final String carModel;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final Address address;
  final double height;
  final double width;
  @override
  Widget build(BuildContext context) {
    Image carImage = Image.network(imagePath, height: height, width: width, fit: BoxFit.cover,);
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
              TripInfoContainerLarge(carBrand: carBrand, carModel: carModel , address: address, checkInDate: checkInDate, checkOutDate: checkOutDate,)
            ],),
          ),
        ),
      ),
    );
  }
}

class TripPreviewContainer extends StatelessWidget {
  const TripPreviewContainer({
    super.key,
    required this.imagePath,
    required this.carBrand,
    required this.carModel,
    required this.checkInDate,
    required this.checkOutDate,
    required this.address,
    required this.height,
    required this.width
    });

  final String imagePath;
  final String carBrand;
  final String carModel;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final Address address;
  final double height;
  final double width;
  @override
  Widget build(BuildContext context) {
    Image carImage = Image.network(imagePath, height: height, width: width, fit: BoxFit.cover,);
    return IntrinsicWidth(
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0, top: 8, bottom: 12),
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: Color.fromARGB(255, 213, 213, 213), width: 0.5), borderRadius: BorderRadius.circular(22)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
              carImage,
              TripInfoContainer(carBrand: carBrand, carModel: carModel , address: address, checkInDate: checkInDate, checkOutDate: checkOutDate,)
            ],),
          ),
        ),
      ),
    );
  }
}

class TripInfoContainerLarge extends StatelessWidget {
  const TripInfoContainerLarge({
    super.key,
    required this.carBrand,
    required this.carModel,
    required this.address,
    required this.checkInDate,
    required this.checkOutDate
  });

  final String carBrand;
  final String carModel;
  final Address address;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextStyle lightRoboto = GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w300, color: Color.fromARGB(255, 84, 84, 84));
    return Padding(
      padding: const EdgeInsets.only(top:4, bottom:4, left: 8, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${carBrand} ${carModel}", style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 2, right: 2),
                    child: Icon(Icons.location_on_rounded, color: theme.primaryColor, size: 12),
                  ),
                  Container(width: 120, child: Text(address.streetNumber, style: lightRoboto, maxLines: 2,))
                ],
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
            Text("${checkInDate.day}/${checkInDate.month}/${checkInDate.year}", style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w300),),
            Text("${checkOutDate.day}/${checkOutDate.month}/${checkOutDate.year}", style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w300),),
          ],)
        ],
      ),
    );
  }
}


class TripInfoContainer extends StatelessWidget {
  const TripInfoContainer({
    super.key,
    required this.carBrand,
    required this.carModel,
    required this.address,
    required this.checkInDate,
    required this.checkOutDate
  });

  final String carBrand;
  final String carModel;
  final Address address;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextStyle lightRoboto = GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w300, color: Color.fromARGB(255, 84, 84, 84));
    return Padding(
      padding: const EdgeInsets.only(top:4, bottom:4, left: 8, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${carBrand} ${carModel}", style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 2, right: 2),
                    child: Icon(Icons.location_on_rounded, color: theme.primaryColor, size: 12),
                  ),
                  Container(width: 120, child: Text(address.streetNumber, style: lightRoboto, maxLines: 2,))
                ],
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
            Text("${checkInDate.day}/${checkInDate.month}/${checkInDate.year}", style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w300),),
            Text("${checkOutDate.day}/${checkOutDate.month}/${checkOutDate.year}", style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w300),),
          ],)
        ],
      ),
    );
  }
}


class CarSpecs extends StatelessWidget {
  const CarSpecs({
    required this.transmission,
    required this.nbSeats,
    required this.fuel,
    super.key,
  });
  final String transmission;
  final int nbSeats;
  final String fuel;
  @override
  Widget build(BuildContext context) {
    Map<String, String> transmissions = {"M": "Manual", "A": "Automatic", "S":"Semi-automatic"};
    Map<String, String> fuels = {"D": "Diesel", "G": "Gas", "E":"Electric", "H":"Hybrid"};
    return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 50,
                        child: Column(
                          children: [
                            Text("Transmission", style: lightRobotoSmall,),
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
                              child: SvgPicture.asset("assets/icons/transmission.svg", height: 20),
                            ),
                            Text("${transmissions[transmission]}", style: boldRobotoSmall,)
                          ],),
                      ),
                     Container(
                      width: 50,
                       child: Column(
                          children: [
                            Text("Seats", style: lightRobotoSmall),
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
                              child: SvgPicture.asset("assets/icons/seat.svg", height: 20),
                            ),
                            Text("${nbSeats}", style: boldRobotoSmall)
                          ],),
                     ),
                     Container(
                      width: 50,
                       child: Column(
                          children: [
                            Text("Energy", style: lightRobotoSmall),
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
                              child: SvgPicture.asset(fuel == "E" ? "assets/icons/energy-electric.svg" : "assets/icons/energy-fuel.svg", height: 20),
                            ),
                            Text("${fuels[fuel]}", style: boldRobotoSmall)
                          ],),
                     ),
                    ],
                   );
  }
}