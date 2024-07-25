class Address {
  final String city;
  final String postalCode;
  final String province;
  final String streetNumber;

  Address({
    required this.city,
    required this.postalCode,
    required this.province,
    required this.streetNumber,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      city: map['city'],
      postalCode: map['postal_code'],
      province: map['province'],
      streetNumber: map['street_number'],
    );
  }
  Map<String, String> toMap() {
    return {
      'city': city,
      'postal_code': postalCode,
      'province': province,
      'street_number': streetNumber,
    };
  }
}