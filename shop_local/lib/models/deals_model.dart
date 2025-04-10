import 'package:cloud_firestore/cloud_firestore.dart';

class Deal {
  String? id;
  final String title;
  final String? storeName;
  final String? storeImage;
  final String? productImage;
  final double? discountPercentage;
  final String? condition;
  final bool isStoreWide;
  final DateTime expiryDate;
  final String? productId;
  final String? storeId;

  Deal({
    this.id,
    required this.title,
    this.storeName,
    this.storeImage,
    this.productImage,
    this.discountPercentage,
    this.condition,
    required this.isStoreWide,
    required this.expiryDate,
    this.productId,
    this.storeId,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'storeName': storeName,
      'storeImage': storeImage,
      'productImage': productImage,
      'discountPercentage': discountPercentage,
      'condition': condition,
      'isStoreWide': isStoreWide,
      'expiryDate': expiryDate,
      'productId': productId,
      'storeId': storeId,
    };
  }

  factory Deal.fromMap(Map<String, dynamic> data, String documentId) {
    return Deal(
      id: documentId,
      title: data['title'] ?? '',
      storeName: data['storeName'],
      storeImage: data['storeImage'],
      productImage: data['productImage'],
      discountPercentage: data['discountPercentage']?.toDouble(),
      condition: data['condition'],
      isStoreWide: data['isStoreWide'] ?? false,
      expiryDate: (data['expiryDate'] as Timestamp).toDate(),
      productId: data['productId'],
      storeId: data['storeId'],
    );
  }

}