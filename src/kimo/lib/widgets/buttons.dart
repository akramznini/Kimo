import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kimo/utils/theme_values.dart';

class FavoriteToggleButton extends StatefulWidget {
  FavoriteToggleButton({
    super.key,
    this.isFavorite = false,
    required this.size,
    required this.toggleFavoriteCallback
  });
  VoidCallback toggleFavoriteCallback;
  final double size; 
  bool isFavorite; 
  @override
  State<FavoriteToggleButton> createState() => _FavoriteToggleButtonState();
}

class _FavoriteToggleButtonState extends State<FavoriteToggleButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size + 12,
      height: widget.size + 10,
      decoration: BoxDecoration( border: Border.all(color: greySelected, width: 0.5), color: Colors.white, borderRadius: BorderRadius.circular(5)), child: Center(
        child: TextButton(
          style: TextButton.styleFrom(
    padding: EdgeInsets.zero, // Adjust padding as needed
  ),
          child: widget.isFavorite ? Icon(Icons.favorite, color: onPrimary, size: widget.size,) : Icon(Icons.favorite_border, color: onPrimary, size: widget.size,), onPressed: (){
            setState(() {
              widget.isFavorite = !widget.isFavorite;
            });
            widget.toggleFavoriteCallback();}),
      ));
  }
}

Future<void> toggleFavoritesCallback(User ?user, String carDocPath, bool isFavorite) async{
      if (user == null) {
        //TODO: handle user is not signed in
      }
      else {
        print("user is not null");
        try 
        {
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        var userDoc = await firestore.collection("users").where("UID", isEqualTo: user!.uid).get();
        var userDocId = userDoc.docs.first.id;
        if (userDoc.docs.first.exists) {
        List wishlist = userDoc.docs.first.data()["wishlist"] as List;
        if (isFavorite) {
          wishlist.remove(carDocPath);
        }

        else {
          wishlist.add(carDocPath);
        }
        print("user docId: ${userDocId}");
        await firestore.collection('users').doc(userDocId).update({
        'wishlist': wishlist,
      });

        }

        }
        catch (err) {
          print(err.toString());
        }
          
      }
  }

class CustomButtonWhite extends StatelessWidget {
  const CustomButtonWhite({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.iconSize
  });
  final double iconSize;
  final Icon icon;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: greySelected, width: 0.5)),
        child: IconButton(
        onPressed: onPressed,
        icon: icon,
        iconSize: iconSize,
        color: Colors.black, // Icon color
        splashRadius: 24, // Increase the splash radius to make the button easier to tap 
        padding: EdgeInsets.all(10), // Remove default padding
              ),
      ),
    );
  }
}
