import 'package:flutter/material.dart';

import '../models/story.dart';

class AllStoresSection extends StatelessWidget {
  final List<Story> stories;

  const AllStoresSection({super.key, required this.stories});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            "All Stories",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 400,
          child: ListView.builder(
            itemCount: stories.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.all(8),
                height: 250,
                width: 400,
                child: Image.network(
                  stories[index].imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Image.asset('assets/images/One.png'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
