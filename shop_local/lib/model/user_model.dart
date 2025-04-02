import 'package:cloud_firestore/cloud_firestore.dart';


class UserModel {
  final String? id;
  final String? photoUrl;
  final String accountType;
  final String address;
  final String city;
  final String postalCode;
  final String? licenseNumber;

  UserModel({
    this.id,
    this.photoUrl,
    required this.accountType,
    required this.address,
    required this.city,
    required this.postalCode,
    this.licenseNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'photoUrl': photoUrl,
      'accountType': accountType,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'licenseNumber': licenseNumber,
    };
  }

  static UserModel fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: data['id'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      accountType: data['accountType'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      postalCode: data['postalCode'] ?? '',
      licenseNumber: data['licenseNumber'] ?? '',
    );
  }
}

