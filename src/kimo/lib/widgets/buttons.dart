import 'package:flutter/material.dart';
import 'package:kimo/utils/theme_values.dart';

class FavoriteToggleButton extends StatefulWidget {
  FavoriteToggleButton({
    super.key,
    this.isFavorite = false,
    required this.size
  });
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
            },),
      ));
  }
}