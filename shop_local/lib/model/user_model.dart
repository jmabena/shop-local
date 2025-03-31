import 'package:cloud_firestore/cloud_firestore.dart';


class UserModel {
  final String? id;
  final String? photoUrl;
  final String accountType;
  final String address;
  final String city;
  final String postalCode;
  final String? organizationName;
  final String? organizationDescription;
  final String? organizationType;
  final String? licenseNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    this.id,
    this.photoUrl,
    required this.accountType,
    required this.address,
    required this.city,
    required this.postalCode,
    this.organizationName,
    this.organizationDescription,
    this.organizationType,
    this.licenseNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'photoUrl': photoUrl,
      'accountType': accountType,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'organizationName': organizationName,
      'organizationDescription': organizationDescription,
      'organizationType': organizationType,
      'licenseNumber': licenseNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static UserModel fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: data['id'],
      photoUrl: data['photoUrl'],
      accountType: data['accountType'],
      address: data['address'],
      city: data['city'],
      postalCode: data['postalCode'],
      organizationName: data['organizationName'],
      organizationDescription: data['organizationDescription'],
      organizationType: data['organizationType'],
      licenseNumber: data['licenseNumber'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}

