import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';
import '../models/seller_model.dart';


class SellerController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveSellerInfo(SellerModel sellerInfo) async {
    await _firestore.collection('sellers').doc(sellerInfo.sellerId).set(
      sellerInfo.toMap(),
      SetOptions(merge: true),
    );
  }


  Stream<SellerModel?> getSellerInfo(String userId) {
    return _firestore.collection('sellers').doc(userId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return SellerModel.fromMap(doc.data()!, userId);
      }
      return null;
    });
  }


  Stream<List<SellerModel>> getAllSellersStream() {
    return _firestore.collection('sellers').snapshots().map((querySnapshot) =>
        querySnapshot.docs.map((doc) => SellerModel.fromMap(doc.data(), doc.id)).toList()
    );
  }



  Future<void> addSellerProduct(ProductModel productData, String userId) async {
    try {
      // 1. Create document reference
      final productsCollection = _firestore
          .collection('sellers')
          .doc(userId)
          .collection('products');

      // 2. Generate new document reference
      final newDocRef = productsCollection.doc();

      // 3. Create updated product data with generated ID
      final updatedProduct = productData.copyWith(
        productId: newDocRef.id,
        productUrl: productData.productUrl,
        productName: productData.productName,
        productPrice: productData.productPrice,
        productDesc: productData.productDesc,
        sellerId: productData.sellerId,
      );

      // 4. Set data to the specific document
      await newDocRef.set(updatedProduct.toMap());

    } catch (e) {
      throw FirebaseException(
        plugin: 'addSellerProduct',
        message: 'Failed to add product: $e',
      );
    }
  }

  Stream<List<ProductModel>> getSellerProducts(String? userId) {
    return _firestore
        .collection('sellers')
        .doc(userId)
        .collection('products')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ProductModel.fromMap(doc))
        .toList());
  }

  Stream<List<ProductModel>> getAllProducts() {
    return _firestore
        .collectionGroup('products')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ProductModel.fromMap(doc))
        .toList());
  }

  Future<void> deleteSellerInfo(String userId) async {
    return await _firestore.collection('sellers').doc(userId).delete();
  }

  Future<void> deleteSellerProducts(String userId) async {
    final productsCollection = _firestore.collection('sellers').doc(userId).collection('products');
    final snapshot = await productsCollection.get();

    WriteBatch batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}