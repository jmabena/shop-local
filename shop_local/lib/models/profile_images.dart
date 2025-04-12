class ProfileImages {
  String? imageUrl;
  final String userId;

  ProfileImages({this.imageUrl, required this.userId});

  Map<String, dynamic> toMap() {
    return {
    'imageUrl': imageUrl,
    'userId' : userId,
    };
  }

  factory ProfileImages.fromMap(Map<String, dynamic> map) {
    return ProfileImages(
      imageUrl: map['imageUrl'],
      userId: map['userId'],
    );
  }
}