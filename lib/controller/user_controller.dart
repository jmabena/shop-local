import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as fbAuth;
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserController extends ChangeNotifier {
  final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection('users');
  List<UserModel> _users = [];
  List<UserModel> get users => _users;
  StreamSubscription<QuerySnapshot>? _usersSubscription;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Map<String,String> _usersWithEmail = {};
  Map<String,String> get usersWithEmail => _usersWithEmail;

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

  Future<void> fetchAllUsers() async {
    _isLoading = true;
    notifyListeners();
    _usersSubscription?.cancel();
    _usersSubscription = _usersCollection.snapshots().listen((snapshot) async{
      _users = snapshot.docs.map((doc) => UserModel.fromMap(doc)).toList();
      await _fetchEmailsForUsers();
      _isLoading = false;
      notifyListeners();
    });

  }
  Future<void> _fetchEmailsForUsers() async {
    _usersWithEmail.clear();
    List<Future<void>> emailFutures = [];
    for (UserModel user in _users) {
      emailFutures.add(_getEmailForUser(user));
    }
    await Future.wait(emailFutures);
  }

  Future<void> _getEmailForUser(UserModel user) async {
    try {
      fbAuth.User userRecord = await fbAuth.FirebaseAuth.instance.currentUser!;
      // if user found set the email and id in the map
      if(userRecord.uid == user.id){
        _usersWithEmail[user.id!] = userRecord.email!;
      } else{
        // if user is not current user use another method
        fbAuth.FirebaseAuth.instance.fetchSignInMethodsForEmail(userRecord.email!).then((value) {
          if(value.isNotEmpty){
            _usersWithEmail[user.id!] = userRecord.email!;
          }
        });
      }
    }catch(e){
      print('Error fetching email for user: $e');
    }

  }


}