import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/seller_model.dart';


class SellerController extends ChangeNotifier{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;
  StreamSubscription<QuerySnapshot>? _productsSubscription;
  bool _isListeningToAllProducts = false;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  SellerController();

  Future<void> saveSellerInfo(SellerModel sellerInfo) async {
    await _firestore.collection('sellers').doc(sellerInfo.sellerId).set(
      sellerInfo.toMap(),
      SetOptions(merge: true),
    );
  }


  Stream<SellerModel> getSellerInfo(String? userId) {
    return _firestore.collection('sellers').doc(userId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return SellerModel.fromMap(doc.data()!, userId);
      }
      throw Exception('Seller not found');
    });
  }
  Future<ProductModel> getSellerProduct(String? userId, String? productId) async {
    final doc = await _firestore.collection('sellers').doc(userId).collection('products').doc(productId).get();
    if (doc.exists && doc.data() != null) {
      return ProductModel.fromMap(doc.data()!, productId!);
    }
    throw Exception('Product not found');
  }


  Stream<List<SellerModel>> getAllSellersStream() {
    return _firestore.collection('sellers').snapshots().map((querySnapshot) =>
        querySnapshot.docs.map((doc) => SellerModel.fromMap(doc.data(), doc.id)).toList()
    );
  }

  Future<void> fetchAllProducts() async {
    if (_isListeningToAllProducts) return;
    _isLoading = true;
    notifyListeners();
    _productsSubscription?.cancel();
    _productsSubscription = _firestore.collection('products').snapshots().listen((snapshot) {
      _products = snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
      _isLoading = false;
      notifyListeners();
    });
    _isListeningToAllProducts = true;
  }

  Future<void> fetchSellerProducts(String? sellerId) async {
    _isListeningToAllProducts = false;
    _isLoading = true;
    notifyListeners();
    _productsSubscription?.cancel();
    _productsSubscription = _firestore.collection('sellers').doc(sellerId).collection('products').snapshots().listen((snapshot) {
      _products =
          snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
              .toList();
      _isLoading = false;
      notifyListeners();
    });

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
      notifyListeners();

    } catch (e) {
      throw FirebaseException(
        plugin: 'addSellerProduct',
        message: 'Failed to add product: $e',
      );
    }
  }

  Future<void> updateSellerProduct(ProductModel productData, String userId) async {
    await _firestore.collection('sellers').doc(userId).collection('products').doc(productData.productId).set(productData.toMap());
    notifyListeners();
  }

  Stream<List<ProductModel>> getSellerProducts(String? userId) {
    return _firestore
        .collection('sellers')
        .doc(userId)
        .collection('products')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  Stream<List<ProductModel>> getAllProducts() {
    return _firestore
        .collectionGroup('products')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data(),doc.id))
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
    notifyListeners();
  }

  Future<void> deleteProduct(String userId, String productId) async {
    await _firestore.collection('sellers').doc(userId).collection('products').doc(productId).delete();
    notifyListeners();
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    super.dispose();
  }
}