import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/news_model.dart';

class NewsController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<News>> fetchNews() {
    return _firestore.collection('news').orderBy('date', descending: true).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => News.fromMap(doc.data(), doc.id)).toList(),
    );
  }

  Future<News?> getNewsDetails(String newsId) async {
    final doc = await _firestore.collection('news').doc(newsId).get();
    if (doc.exists) {
      return News.fromMap(doc.data()!, doc.id);
    }
    return null;
  }
}