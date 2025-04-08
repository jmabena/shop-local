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
  Future<List<Deal>> getStoreDeals(String? sellerId) async {
    List<Deal> deals = [];
    deals.addAll( await _firestore.collection('deals').where('sellerId', isEqualTo: sellerId).where('isStoreWide', isEqualTo: false)
        .snapshots().map((snapshot) => snapshot.docs.map((doc) => Deal.fromMap(doc.data(), doc.id)).toList()).first);
    deals.addAll( await _firestore.collection('deals').where('storeId', isEqualTo: sellerId).where('isStoreWide', isEqualTo: false)
        .snapshots().map((snapshot) => snapshot.docs.map((doc) => Deal.fromMap(doc.data(), doc.id)).toList()).first);
    return deals;
  }

  Future<Deal?> getDealForProduct(String productId) async {
    final query = await _firestore.collection('deals').where('productId', isEqualTo: productId).get();
    if (query.docs.isNotEmpty) {
      return Deal.fromMap(query.docs.first.data(), query.docs.first.id);
    }
    return null;
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
  }
}
