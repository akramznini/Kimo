import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kimo/classes/address.dart';

class Trip {
  String tripDocId;
  String carDocPath;
  int dailyRate;
  int duration;
  Timestamp endDate;
  String guestId;
  String hostId;
  double positionLatitude;
  double positionLongitude;
  Timestamp startDate;
  String pictureUrl;
  String carModel;
  String carBrand;
  Address address;
  bool isCancelled;
  bool isReviewed;
  Trip({
    required this.tripDocId,
    required this.carDocPath,
    required this.dailyRate,
    required this.duration,
    required this.endDate,
    required this.guestId,
    required this.hostId,
    required this.positionLatitude,
    required this.positionLongitude,
    required this.startDate,
    required this.pictureUrl,
    required this.carModel,
    required this.carBrand,
    required this.address,
    this.isCancelled = false, // When creating a trip it can't be cancelled from the start
    this.isReviewed = false, // // When creating a trip it can't be reviewed from the start
  });

  factory Trip.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Trip(
      tripDocId: doc.id,
      carDocPath: data['car'] ?? '',
      dailyRate: (data['daily_rate'] ?? 0),
      duration: data['duration'] ?? 0,
      endDate: data['end_date'] ?? Timestamp.now(),
      guestId: data['guest'] ?? '',
      hostId: data['host'] ?? '',
      positionLatitude: (data['position_latitude'] ?? 0).toDouble(),
      positionLongitude: (data['position_longitude'] ?? 0).toDouble(),
      startDate: data['start_date'] ?? Timestamp.now(),
      pictureUrl: data['picture_url'] ?? '',
      carModel: data['model'] ?? '',
      carBrand: data['brand'] ?? '',
      address: Address.fromMap(data['address']),
      isCancelled: data['is_cancelled'],
      isReviewed: data['is_reviewed']
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'address': address.toMap(),
      'car': carDocPath,
      'daily_rate': dailyRate,
      'start_date': startDate,
      'end_date': endDate,
      'model': carModel,
      'brand': carBrand,
      'host': hostId,
      'guest': guestId,
      'picture_url': pictureUrl,
      'position_latitude': positionLatitude,
      'position_longitude': positionLongitude,
      'duration': duration,
      'is_cancelled': isCancelled,
      'is_reviewed': isReviewed
    };
  }
}