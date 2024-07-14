import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class datePreview extends StatefulWidget {
  datePreview({
    super.key,
    required this.dateRange
  });
  DateTimeRange dateRange;
  @override
  State<datePreview> createState() => _datePreviewState();
}


class _datePreviewState extends State<datePreview> {
  void setDateRange(DateTimeRange newDateRange){
  setState((){
    widget.dateRange = newDateRange;
  });   
}

  @override
  Widget build(BuildContext context) {
    return 
      Column(children: [
        
      ],);
  }
}