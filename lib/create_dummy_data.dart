import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/seller_model.dart';
import '../models/product_model.dart';
import '../models/deals_model.dart';

class DummyDataGenerator {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> generateDummyData() async {
    for (int i = 1; i <= 3; i++) {
      final sellerId = 'seller_$i';
      final seller = SellerModel(
        sellerId: sellerId,
        logoUrl: 'https://example.com/logo_$i.png',
        picUrl: 'https://example.com/pic_$i.png',
        organizationName: 'Business $i',
        organizationType: 'Retail',
        organizationDesc: 'A great business selling awesome products.',
      );
      await _firestore.collection('sellers').doc(sellerId).set(seller.toMap());

      for (int j = 1; j <= 5; j++) {
        final productId = 'product_${i}_$j';
        final product = ProductModel(
          productId: productId,
          productUrl: 'https://example.com/product_$j.png',
          productName: 'Product $j',
          productPrice: (10 + j * 2).toDouble(),
          productDesc: 'High-quality product.',
          sellerId: sellerId,
        );
        await _firestore.collection('sellers').doc(sellerId).collection('products').doc(productId).set(product.toMap());
      }

      final isStoreWide = i % 2 == 0;
      final deal = Deal(
        id: 'deal_$i',
        title: isStoreWide ? 'Store-wide Discount!' : 'Product Discount! $i',
        storeName: seller.organizationName,
        storeImage: seller.logoUrl,
        productImage: isStoreWide ? null : 'https://example.com/product_1.png',
        discountPercentage: isStoreWide ? null : 10.0,
        condition: isStoreWide ? 'Spend \$50 and get 10% off' : 'Limited-time offer!',
        isStoreWide: isStoreWide,
        expiryDate: DateTime.now().add(Duration(days: 7)),
      );
      await _firestore.collection('deals').doc(deal.id).set({
        'title': deal.title,
        'storeName': deal.storeName,
        'storeImage': deal.storeImage,
        'productImage': deal.productImage,
        'discountPercentage': deal.discountPercentage,
        'condition': deal.condition,
        'isStoreWide': deal.isStoreWide,
        'expiryDate': Timestamp.fromDate(deal.expiryDate),
      });
    }
  }
}
