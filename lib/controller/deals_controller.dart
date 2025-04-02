import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/deals_model.dart';

class DealsController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Deal>> fetchDeals() {
    return _firestore.collection('deals').orderBy('expiryDate', descending: false).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Deal.fromMap(doc.data(), doc.id)).toList(),
    );
  }
}
