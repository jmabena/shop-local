import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserController {
  final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection('users');

  Future<void> saveUser(UserModel user) async {
    return await _usersCollection.doc(user.id).set(user.toMap());
  }

  Future<void> deleteUser(String uid) async {
    return await _usersCollection.doc(uid).delete();
  }

  Stream<UserModel> getCurrentUser() {
    return _usersCollection
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((snapshot) => UserModel.fromMap(snapshot));
  }

  Future<void> saveProfileImage(String photoUrl) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    return await _usersCollection.doc(uid).update({
      'photoUrl': photoUrl,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

}