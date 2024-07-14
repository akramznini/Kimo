import 'package:flutter/material.dart';
import 'package:kimo/utils/theme_values.dart';

class FavoriteToggleButton extends StatefulWidget {
  FavoriteToggleButton({
    super.key,
    this.isFavorite = false,
    required this.carDocPath
  });
  bool isFavorite; 
  String carDocPath;
  @override
  State<FavoriteToggleButton> createState() => _FavoriteToggleButtonState();
}

class _FavoriteToggleButtonState extends State<FavoriteToggleButton> {
  @override
  Widget build(BuildContext context) {
    return Container(decoration: BoxDecoration(border: Border.all(color: greySelected, width: 0.5), color: Colors.white, borderRadius: BorderRadius.circular(8)), child: IconButton(icon: widget.isFavorite ? Icon(Icons.favorite, color: onPrimary,) : Icon(Icons.favorite_border, color: onPrimary,), iconSize: 20 ,onPressed: (){
      setState((){
        widget.isFavorite = !widget.isFavorite;
      });
    },));
  }
}