
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/news_controller.dart';
import '../model/news_model.dart';

class NewsDetailsPage extends StatelessWidget {
  final String newsId;

  NewsDetailsPage({required this.newsId});

  @override
  Widget build(BuildContext context) {
    final newsController = Provider.of<NewsController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text('News Details')),
      body: FutureBuilder<News?>(
        future: newsController.getNewsDetails(newsId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('News not found.'));
          }

          final news = snapshot.data!;
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(news.imageUrl, width: double.infinity, height: 200, fit: BoxFit.cover),
                SizedBox(height: 10),
                Text(news.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text(news.date.toLocal().toString().split(' ')[0], style: TextStyle(color: Colors.grey)),
                SizedBox(height: 10),
                Expanded(child: SingleChildScrollView(child: Text(news.content))),
              ],
            ),
          );
        },
      ),
    );
  }
}
