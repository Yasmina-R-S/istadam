class Post {
  int? id;
  int userId;
  String image;
  String description;
  String date;
  int likes;
  int commentCount; // número de comentarios

  Post({
    this.id,
    required this.userId,
    required this.image,
    required this.description,
    required this.date,
    this.likes = 0,
    this.commentCount = 0, // inicializamos a 0
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'image': image,
      'description': description,
      'date': date,
      'likes': likes,
      // commentCount no hace falta guardar en DB
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      userId: map['userId'],
      image: map['image'],
      description: map['description'],
      date: map['date'],
      likes: map['likes'],
      commentCount: 0,
    );
  }
}
