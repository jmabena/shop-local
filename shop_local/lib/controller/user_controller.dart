import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/user_model.dart';

class UserController {
  final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection('users');

  Future<String> get _currentUserAccountType async {
    final userDoc = await _usersCollection.doc(FirebaseAuth.instance.currentUser!.uid).get();
    return userDoc['accountType']; // Ensure the field exists in the document
  }

  Future<void> saveUser(UserModel user) async {
    return await _usersCollection.doc(user.id).set(user.toMap());
  }

  Future<void> deleteUser(String uid) async {
    return await _usersCollection.doc(uid).delete();
  }

  Stream<List<UserModel>> getSellers() {
    return _usersCollection
        .where('accountType', isEqualTo: 'seller')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => UserModel.fromMap(doc))
        .toList());
  }

  Stream<UserModel> getCurrentUser() {
    return _usersCollection
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((snapshot) => UserModel.fromMap(snapshot));
  }

  CollectionReference get _sellerSubcollection {
    return _usersCollection
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('seller_data');
  }


  Future<void> addSellerProduct(Map<String, dynamic> productData) async {
    final accountType = await _currentUserAccountType;
    if (accountType != 'seller') {
      throw Exception('Only sellers can add products');
    }
    await _sellerSubcollection.add(productData);
  }
}