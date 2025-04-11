
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/news_controller.dart';
import '../model/news_model.dart';
import 'news_details_screen.dart';

class NewsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final newsController = Provider.of<NewsController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text('News')),
      body: StreamBuilder<List<News>>(
        stream: newsController.fetchNews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No news available.'));
          }

          final newsList = snapshot.data!;
          return ListView.builder(
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final news = newsList[index];
              return ListTile(
                leading: Image.network(news.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                title: Text(news.title),
                subtitle: Text(news.date.toLocal().toString().split(' ')[0]),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewsDetailsPage(newsId: news.id)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}