///PRODUCT MODEL FROM ETOM
import 'package:cloud_firestore/cloud_firestore.dart';


class ProductModel {
  final String? productId;
  final String? productUrl;
  final String productName;
  final double productPrice;
  final String productDesc;
  final String sellerId;
  final bool hasDeal;

  ProductModel({
    this.productId,
    this.productUrl,
    required this.productName,
    required this.productPrice,
    required this.productDesc,
    required this.sellerId,
    this.hasDeal = false,
  });

  ProductModel copyWith({
    String? productId,
    String? productUrl,
    required String productName,
    required double productPrice,
    required String productDesc,
    required String sellerId,
    bool? hasDeal,
  }) {
    return ProductModel(
      productId: productId ?? this.productId,
      productUrl: productUrl ?? this.productUrl,
      productName: productName,
      productPrice: productPrice,
      productDesc: productDesc,
      sellerId: sellerId,
      hasDeal: hasDeal ?? this.hasDeal,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productUrl': productUrl,
      'productName': productName,
      'productPrice': productPrice,
      'productDesc': productDesc,
      'sellerId': sellerId,
      'hasDeal': hasDeal,
    };
  }

  static ProductModel fromMap(Map<String, dynamic> data, String documentId) {
    return ProductModel(
      productId: documentId,
      productUrl: data['productUrl'] ?? '',
      productName: data['productName'],
      productPrice: data['productPrice'],
      productDesc: data['productDesc'],
      sellerId: data['sellerId'] ?? '',
      hasDeal: data['hasDeal'] ?? false,
    );
  }
}
