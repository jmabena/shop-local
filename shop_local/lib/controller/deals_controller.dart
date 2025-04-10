import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/deals_model.dart';

class DealsController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Deal> _deals = [];
  List<Deal> get deals => _deals;
  StreamSubscription<QuerySnapshot>? _dealsSubscription;
  bool _isListeningToAllDeals = false;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DealsController();

  Future<void> fetchAllDeals() async {
    if (_isListeningToAllDeals) return;
    _isLoading = true;
    notifyListeners();
    _dealsSubscription?.cancel();
    _dealsSubscription = _firestore.collection('deals').orderBy('expiryDate', descending: false).snapshots().listen((snapshot) {
      _deals = snapshot.docs.map((doc) => Deal.fromMap(doc.data(), doc.id)).toList();
      _isLoading = false;
      notifyListeners();
    });
    _isListeningToAllDeals = true;

  }

  Future<void> fetchStoreDeals(String? sellerId) async {
    _isListeningToAllDeals = false;
    _isLoading = true;
    notifyListeners();
    _dealsSubscription?.cancel();
    _dealsSubscription = _firestore.collection('deals').where('sellerId', isEqualTo: sellerId).snapshots().listen((snapshot) {
      _deals = snapshot.docs.map((doc) => Deal.fromMap(doc.data(), doc.id)).toList();
      _isLoading = false;
      notifyListeners();
    });
    _firestore.collection('deals').where('storeId', isEqualTo: sellerId).where('isStoreWide', isEqualTo: false).snapshots().listen((snapshot) {
      _deals = snapshot.docs.map((doc) => Deal.fromMap(doc.data(), doc.id)).toList();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addDeal(Deal deal,String? productId,String sellerId) async {
    var dealData = await _firestore.collection('deals').add(deal.toMap());
    await _firestore.collection('sellers').doc(sellerId).collection('deals').doc(dealData.id).set({
      'isStoreWide' : deal.isStoreWide,
      'expiryDate' : deal.expiryDate,
    });
    await _firestore.collection('sellers').doc(sellerId).update({'hasDeal': true});
    if(productId != null){
      await _firestore.collection('sellers').doc(sellerId).collection('products').doc(productId).update({'hasDeal': true});
    }
    _deals.add(deal);
    notifyListeners();
  }

  @override
  void dispose() {
    _dealsSubscription?.cancel();
    super.dispose();
  }
}