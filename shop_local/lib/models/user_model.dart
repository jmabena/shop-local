import 'package:cloud_firestore/cloud_firestore.dart';


class UserModel {
  final String? uid;
  final String? photoUrl;
  final String email;
  final String userType;
  final String address;
  final String city;
  final String postalCode;
  final String createdAt;
  final String updatedAt;

  UserModel({
    this.uid,
    this.photoUrl,
    required this.email,
    required this.userType,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'userType': userType,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static UserModel fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      email: data['email'] ?? '',
      userType: data['userType'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      postalCode: data['postalCode'] ?? '',
      createdAt: data['createdAt'] ?? '',
      updatedAt: data['updatedAt'] ?? '',
    );
  }
}

