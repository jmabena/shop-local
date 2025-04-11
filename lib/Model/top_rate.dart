class TopRate {
  final String id;
  final String imageUrl;

  TopRate({required this.id, required this.imageUrl});

  factory TopRate.fromMap(Map<String, dynamic> data) {
    return TopRate(
      id: data['id'],
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
    };
  }
}
