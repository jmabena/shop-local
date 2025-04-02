import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shop_local/model/product_model.dart';
import 'package:shop_local/model/seller_model.dart';
import '../model/user_model.dart';

class UserController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection('users');

  Future<void> saveUser(UserModel user) async {
    return await _usersCollection.doc(user.id).set(user.toMap());
  }

  Future<void> deleteUser(String uid) async {
    return await _usersCollection.doc(uid).delete();
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


  Stream<UserModel> getCurrentUser() {
    return _usersCollection
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((snapshot) => UserModel.fromMap(snapshot));
  }

  Stream<SellerModel?> getSellerInfo(String userId) {
   return _firestore.collection('sellers').doc(userId).snapshots().map((doc) {
     if (doc.exists && doc.data() != null) {
       return SellerModel.fromMap(doc.data()!);
     }
     return null;
   });
  }


  Future<void> saveSellerInfo(SellerModel sellerInfo) async {
    await _firestore.collection('sellers').doc(sellerInfo.sellerId).set(
      sellerInfo.toMap(),
      SetOptions(merge: true),
    );
  }

  Stream<List<SellerModel>> getAllSellersStream() {
    return _firestore.collection('sellers').snapshots().map((querySnapshot) =>
        querySnapshot.docs.map((doc) => SellerModel.fromMap(doc.data())).toList()
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

  Stream<List<ProductModel>> getSellerProducts(String userId) {
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