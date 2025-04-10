import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserController extends ChangeNotifier {
  final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection('users');

  Future<void> saveUser(UserModel user) async {
    return await _usersCollection.doc(user.uid).set(user.toMap());
  }

  Future<void> deleteUser(String uid) async {
    return await _usersCollection.doc(uid).delete();
  }

  Stream<UserModel> getCurrentUser(String userId) {
    return _usersCollection
        .doc(userId)
        .snapshots()
        .map((snapshot) => UserModel.fromMap(snapshot));
  }

  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _usersCollection.get();
    return snapshot.docs.map((doc) => UserModel.fromMap(doc)).toList();
  }

  Future<UserModel?> getUserById(String userId) async {
    final doc = await _usersCollection.doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc);
    }
    return null;
  }


  Future<void> saveProfileImage(String photoUrl) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    return await _usersCollection.doc(uid).update({
      'photoUrl': photoUrl,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

}