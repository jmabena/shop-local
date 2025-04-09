class Story {
  final String id;
  final String imageUrl;
  final String categoryId;
  final String title;

  Story({required this.id, required this.imageUrl, required this.categoryId , required this.title});

  factory Story.fromMap(Map<String, dynamic> data) {
    return Story(
      id: data['id'],
      imageUrl: data['imageUrl'],
      categoryId: data['categoryId'],
      title:data['title'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'title':title,
    };
  }
}
