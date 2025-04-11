import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/category.dart';
import '../model/story.dart';
import '../model/top_rate.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get All Categories
  Future<List<Category>> getCategories() async {
    var snapshot = await _firestore.collection('categories').get();
    return snapshot.docs.map((doc) => Category.fromMap(doc.data())).toList();
  }

  // Get All Stores With Category Filter
  Future<List<Story>> getStoriesByCategory(String categoryId) async {
    var snapshot = await _firestore
        .collection('stories')
        .where('categoryId', isEqualTo: categoryId)
        .get();
    return snapshot.docs.map((doc) => Story.fromMap(doc.data())).toList();
  }

  // Get All Stores
  Future<List<Story>> getAllStories() async {
    var snapshot = await _firestore.collection('stories').get();
    return snapshot.docs.map((doc) => Story.fromMap(doc.data())).toList();
  }

  // Get All TopRate Pictures
  Future<List<TopRate>> getTopRates() async {
    var snapshot = await _firestore.collection('topRates').get();
    return snapshot.docs.map((doc) => TopRate.fromMap(doc.data())).toList();
  }
}
