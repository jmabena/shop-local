import 'package:cloud_firestore/cloud_firestore.dart';


class ProductModel {
  final String? productId;
  final String productUrl;
  final String productName;
  final double productPrice;
  final String productDesc;
  final String sellerId;

  ProductModel({
    this.productId,
    required this.productUrl,
    required this.productName,
    required this.productPrice,
    required this.productDesc,
    required this.sellerId,

  });

  ProductModel copyWith({
    String? productId,
    String? productUrl,
    required String productName,
    required double productPrice,
    required String productDesc,
    required String sellerId,
  }) {
    return ProductModel(
      productId: productId ?? this.productId,
      productUrl: productUrl ?? this.productUrl,
      productName: productName,
      productPrice: productPrice,
      productDesc: productDesc,
      sellerId: sellerId,
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
    };
  }

  static ProductModel fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      productId: data['productId'],
      productUrl: data['productUrl'] ?? '',
      productName: data['productName'],
      productPrice: data['productPrice'],
      productDesc: data['productDesc'],
      sellerId: data['sellerId'] ?? '',
    );
  }
}

