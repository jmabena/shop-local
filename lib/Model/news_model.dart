import 'package:cloud_firestore/cloud_firestore.dart';

/// News Model
class News {
  final String id;
  final String title;
  final String content;
  final String imageUrl;
  final DateTime date;

  News({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.date,
  });

  factory News.fromMap(Map<String, dynamic> data, String documentId) {
    return News(
      id: documentId,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }
}