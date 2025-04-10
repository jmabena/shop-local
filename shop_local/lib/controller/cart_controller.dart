import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/product_model.dart';

class CartController extends ChangeNotifier{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addToCart(ProductModel product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(product.productId); // Use productId as the doc ID

    final doc = await docRef.get();

    if (doc.exists) {
      // If the product is already in cart, increment the count
      await docRef.update({
        'count': FieldValue.increment(1),
      });
    } else {
      // Otherwise, set the document with count = 1
      await docRef.set({
        ...product.toMap(),
        'count': 1,
      });
    }
  }

  Stream<int> getCartItemCount() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .snapshots()
        .map((snapshot) => snapshot.docs.fold<int>(
        0, (total, doc) => total + (doc['count'] as int? ?? 0)));
  }


  /// Returns a stream of cart entries for the current user.
  Stream<List<Map<String, dynamic>>> getCartEntries() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) {
      final data = doc.data();
      return {
        'product': ProductModel.fromMap(doc.data(), doc.id),
        'count': data['count'],
      };
    })
        .toList());
  }

  /// Deletes all cart entries for the current user.
  Future<void> deleteAllCartEntries() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    final cartCollection = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart');

    final snapshot = await cartCollection.get();
    WriteBatch batch = _firestore.batch();

    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Future<void> removeOneFromCart(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    final cartCollection = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart');

    final querySnapshot = await cartCollection
        .where('productId', isEqualTo: productId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final docRef = querySnapshot.docs.first.reference;
      final currentCount = querySnapshot.docs.first['count'];

      if (currentCount > 1) {
        await docRef.update({
          'count': FieldValue.increment(-1),
        });
      } else {
        await docRef.delete(); // Remove if only one left
      }
    }
  }

}