import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/product_model.dart';

class CartController{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addToCart(ProductModel product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    // Reference to the current user's cart collection.
    final cartCollection = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart');

    // Query for an existing cart item with the same product id.
    final querySnapshot = await cartCollection
        .where('productId', isEqualTo: product.productId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // If found, update the count.
      final docRef = querySnapshot.docs.first.reference;
      await docRef.update({
        'count': FieldValue.increment(1),
      });
    } else {
      // If not found, add a new document with count set to 1.
      await cartCollection.add({
        ...product.toMap(),
        'count': 1,
      });
    }
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
        'product': ProductModel.fromMap(doc),
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
}