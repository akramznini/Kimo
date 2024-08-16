import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kimo/classes/car.dart';
import 'package:kimo/classes/city.dart';
import 'package:kimo/classes/firebase_query_builder.dart';
import 'package:kimo/classes/listing.dart';
import 'package:kimo/classes/listing_owner.dart';
import 'package:kimo/classes/trip.dart';
import 'package:kimo/screens/listing_details.dart';
import 'package:kimo/utils/helper_functions.dart';
import 'package:kimo/utils/theme_values.dart';
import 'package:kimo/widgets/buttons.dart';
import 'package:kimo/widgets/car_widgets.dart';
import 'package:kimo/widgets/widgets.dart';


class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({
    super.key,
    required this.city,
    required this.dateTimeRange,
    required this.goToTab
  });
  final void Function(int) goToTab;
  final String city;
  final DateTimeRange dateTimeRange;
  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {

  late Future<List<Listing>> listingsFuture;
  var db = FirebaseFirestore.instance;
  Map<String, dynamic> fuelVariants = {};
  Map<String, dynamic> transmissionVariants = {};
  List<int> seatsList = [];
  List<String> brandList = [];
  List<String> modelList = [];
  late String brandDocID;
  List<TextEditingController> controllers = List.generate(7, (index) => TextEditingController());
  List<QueryFilter> filters = [];
  bool isEnabledModelInput = false;
  bool firstBuild = true;
  List<Listing> originalListings = [];

  Future<List<Listing>> fetchlistingsData(List<QueryFilter> filters) async {
      List<Listing> listings = [];
      try {
        await fetchFilterValues();

        Query initialQuery = db.collection("listings").where("city", isEqualTo: widget.city).where("start_date", isLessThanOrEqualTo: Timestamp.fromDate(widget.dateTimeRange.start))
                      .where("end_date", isGreaterThanOrEqualTo: Timestamp.fromDate(widget.dateTimeRange.end));

        QueryBuilder queryBuilder = QueryBuilder(initialQuery);

        Query filteredQuery = queryBuilder.applyQueryFilters(filters).build().orderBy("rating", descending: true);

        QuerySnapshot listingDocsSnapshot = await filteredQuery.get();
        for (DocumentSnapshot doc in listingDocsSnapshot.docs) {
          print("car data:  ${doc.data()}");
          listings.add(Listing.fromFirestore(doc));
        }
        return listings;
      }
      catch (err) {
        print(err.toString());
        return Future.error(err);
      } 
  }

  void updateFilters() {
    filters = [];
    for (int i = 0; i < controllers.length; i++) {
      if (controllers[i].text.isEmpty) {
        continue;
      }
      else {
        var controller = controllers[i];
        switch (i) {
          case 0:
            filters.add(QueryFilter(attribute: "daily_rate", type: QueryFilterType.isGreaterThanOrEqualTo, value: int.parse(controller.text)));
            break;
          case 1:
            filters.add(QueryFilter(attribute: "daily_rate", type: QueryFilterType.isLessThanOrEqualTo, value: int.parse(controller.text)));
            break;
          case 2:
            filters.add(QueryFilter(attribute: "fuel", type: QueryFilterType.isEqualTo, value: fuelVariants[controller.text]));
            break;
          case 3:
            filters.add(QueryFilter(attribute: "transmission", type: QueryFilterType.isEqualTo, value: transmissionVariants[controller.text]));
            break;
          case 4:
            filters.add(QueryFilter(attribute: "nb_seats", type: QueryFilterType.isEqualTo, value: int.parse(controller.text)));
            break;
          case 5:
            filters.add(QueryFilter(attribute: "brand", type: QueryFilterType.isEqualTo, value: controller.text));
            break;
          case 6:
            filters.add(QueryFilter(attribute: "model", type: QueryFilterType.isEqualTo, value: controller.text));
            break;
        }
      }
    }
  }

  Future<void> fetchFilterValues() async {
    fuelVariants = (await db.collection("car_features").where("feature", isEqualTo: "fuel").get()).docs.first.data()["variants"];
    transmissionVariants = (await db.collection("car_features").where("feature", isEqualTo: "transmission").get()).docs.first.data()["variants"];
    seatsList = List<int>.from((await db.collection("car_features").where("feature", isEqualTo: "nb_seats").get()).docs.first.data()["variants"]);
    var brandDocSnapshot = (await db.collection("car_features").where("feature", isEqualTo: "brand").get()).docs.first;
    brandDocID = brandDocSnapshot.id;
    brandList = List<String>.from(brandDocSnapshot.data()!["variants"]);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listingsFuture = fetchlistingsData(filters);
  }
  List<Listing> filterListings(List<QueryFilter> filters) {
    List<Map<String, dynamic>> listingsData = originalListings.map((element){return element.toMapWithDocId();}).toList();
    for (var filter in filters) {
      switch (filter.type) {
        case QueryFilterType.isEqualTo:
          listingsData = listingsData.where((listing) { return listing[filter.attribute] == filter.value;}).toList();
          break;
        case QueryFilterType.isGreaterThanOrEqualTo:
          listingsData = listingsData.where((listing) { return listing[filter.attribute] >= filter.value;}).toList();
          break;
        case QueryFilterType.isGreaterThan:
          listingsData = listingsData.where((listing) { return listing[filter.attribute] > filter.value;}).toList();
          break;
        case QueryFilterType.isLessThanOrEqualTo:
          listingsData = listingsData.where((listing) { return listing[filter.attribute] <= filter.value;}).toList();
          break;
        case QueryFilterType.isLessThan:
          listingsData = listingsData.where((listing) { return listing[filter.attribute] < filter.value;}).toList();
          break;
      }
    }
    return listingsData.map((element){return Listing.fromMap(element);}).toList();
  }

  void refreshListings() {
    print("filters: ${filters.length}");
    print("originalListings length ${originalListings.length}");
    setState(() {
      listingsFuture = Future<List<Listing>>.delayed(Duration.zero, (){
        return filterListings(filters);
      });
    });
  }
  
  void showFiltersDialog(context, VoidCallback updateUI) {
    showDialog(context: context, builder: (context){
                                          
                                          
                                          return StatefulBuilder(
                                            builder: (stfContext, stfSetState) {
                                             return Dialog(
                                              child: Container(
                                                height: 460,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(16.0),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Container(width: 100, child: FilterTextField(controller: controllers[0], suffix: "\$", inputFormatters: [FilteringTextInputFormatter.digitsOnly], keyboardType: TextInputType.number, label: Text("Minimum"),)),
                                                              Text("-", style: boldRobotoBlack,),
                                                              Container(width: 100, child: FilterTextField(controller: controllers[1], suffix: "\$", inputFormatters: [FilteringTextInputFormatter.digitsOnly], keyboardType: TextInputType.number, label: Text("Maximum"),)),
                                                              
                                                            ],
                                                          ),
                                                          SizedBox(height: 24,),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                            Container(width: 100, child: FilterSelector(controller: controllers[2], elements: fuelVariants.keys.toList(), tileTextAlign: TextAlign.start, label: Text("Fuel"),)),
                                                            Text("-", style: boldRobotoBlack,),
                                                            Container(width: 100, child: FilterSelector(controller: controllers[3], elements: transmissionVariants.keys.toList(), tileTextAlign: TextAlign.start, label: Text("Transmission"),)),
                                                          ],),
                                                          SizedBox(height: 24,),
                                                          FilterSelector(controller: controllers[4], elements: seatsList.map((x) => x.toString()).toList(), tileTextAlign: TextAlign.start, label: Text("Seats"),inputFormatters: [FilteringTextInputFormatter.digitsOnly], keyboardType: TextInputType.number),
                                                          SizedBox(height: 24,),
                                                          FilterSelector(controller: controllers[5], elements: brandList, tileTextAlign: TextAlign.start, label: Text("Brand"), onSelected: () async {
                                                            try {
                                                              var modelListTemp = List<String>.from((await db.collection("car_features").doc(brandDocID).collection("models").where("brand", isEqualTo: controllers[5].text).get()).docs.first.data()["variants"]);
                                                              stfSetState(() {
                                                                modelList = modelListTemp;
                                                                isEnabledModelInput = true;
                                                              },);
                                                              }
                                            
                                                            catch (e) {
                                                              print("Brand FilterSelector error: $e");
                                                            }
                                            
                                                            
                                                            
                                                            },),
                                                          SizedBox(height: 24,),
                                                          FilterSelector(controller: controllers[6], elements: modelList, tileTextAlign: TextAlign.start, label: Text("Model"), enabled: isEnabledModelInput,)
                                                      ],),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                      Navigator.of(context).pop();
                                                      updateFilters();
                                                      updateUI();
                                                  }, child: Padding(
                                                    padding: const EdgeInsets.only(left: 30, right: 30),
                                                    child: Text("FIND CARS", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),),
                                                                              ),                style: ElevatedButton.styleFrom(backgroundColor: onPrimary),)
                                                    ],
                                                  ),
                                                ),
                                              )
                                            );
                                        });
                                        });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(future: listingsFuture, builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Listing> listings = snapshot.data!;
            if (firstBuild) {
              originalListings = listings.map((element) => element).toList();
              firstBuild = false;
            }
            Widget body;
            if (listings.isEmpty) {
              body = Center(child: Text("no results avaialable for current search"));
            }
            else {
              List<Widget> listingWidgets = [];
              for (var listing in listings) {
                listingWidgets.add(
                  Center(child: CarPreviewContainerWithPrice(onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                      return ListingDetails(goToTab: widget.goToTab, carDocPath: listing.carId, listing: listing, dateTimeRange: widget.dateTimeRange,);
                    }));
                  }, dailyRate: listing.dailyRate, imageUrl: listing.pictureUrl, brand: listing.brand, model: listing.model, nbReviews: listing.nbReviews, rating: listing.rating, height: 200, width: min(MediaQuery.of(context).size.width -50, 300)),)
                );
              }
              body = ListView(children: listingWidgets,);
        
            }
            return Scaffold(
              body: Column(
                children: [
                  Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                  
                        child: Row(
                          children: [
                            CustomButtonWhite(iconSize: 20, icon:Icon(Icons.arrow_back), onPressed: (){Navigator.pop(context);},),
                            Expanded(
                              child: GestureDetector(
                                onTap: (){Navigator.of(context).pop();},
                                child: Container(
                                  decoration: BoxDecoration(border: Border.all(color: greySelected, width: 1), borderRadius: BorderRadius.circular(15)),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                        Text(widget.city, style: boldRobotoBlack,),
                                        Text("${dateTimeToString(widget.dateTimeRange.start, showYear: false, showDay: false)} - ${dateTimeToString(widget.dateTimeRange.end, showYear: false, showDay: false)}", style: lightRoboto,)
                                      ],),
                                      IconButton(onPressed: (){
                                        showFiltersDialog(context, refreshListings);
                                      }, icon: Icon(Icons.filter_alt_outlined, size: 15,))
                                    ],),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: body),
                ],
                ),
            );
          }
        
          else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
        
          else {
            return CenteredCircularProgressIndicator();
          }
        
        }),
      ),
    );
  }
}

class FilterTextField extends StatelessWidget {
  const FilterTextField({
    super.key,
    this.hintText,
    this.suffix,
    this.keyboardType,
    this.inputFormatters,
    this.label,
    this.controller,
    this.obscureText = false
  });
  final String ?hintText;
  final bool obscureText;
  final List<TextInputFormatter> ?inputFormatters;
  final TextInputType ?keyboardType;
  final String ?suffix;
  final Widget ?label; 
  final TextEditingController ?controller;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: greySelected),
      
      
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: TextField(obscureText: obscureText, controller: controller, keyboardType: keyboardType, inputFormatters: inputFormatters, decoration: InputDecoration(hintText: hintText, label: label, labelStyle: boldRobotoBlack, border: InputBorder.none, suffix: suffix==null ? null : Text(suffix!, style: boldRobotoBlack,)), style: blackRobotoRegular,),
      ),);
  }
}


class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    this.hintText,
    this.suffix,
    this.keyboardType,
    this.inputFormatters,
    this.label,
    this.controller,
    this.validator,
    this.obscureText = false
  });
  final String? Function(String?)? validator;
  final String ?hintText;
  final bool obscureText;
  final List<TextInputFormatter> ?inputFormatters;
  final TextInputType ?keyboardType;
  final String ?suffix;
  final Widget ?label; 
  final TextEditingController ?controller;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: greySelected),
      
      
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: TextFormField(validator: validator, obscureText: obscureText, controller: controller, keyboardType: keyboardType, inputFormatters: inputFormatters, decoration: InputDecoration(hintText: hintText, label: label, labelStyle: boldRobotoBlack, border: InputBorder.none, suffix: suffix==null ? null : Text(suffix!, style: boldRobotoBlack,)), style: blackRobotoRegular,),
      ),);
  }
}