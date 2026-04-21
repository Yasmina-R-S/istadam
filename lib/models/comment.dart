class Comment {
  int? id;
  int postId;
  String username;
  String text;
  String date;

  Comment({
    this.id,
    required this.postId,
    required this.username,
    required this.text,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'username': username,
      'text': text,
      'date': date,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      postId: map['postId'],
      username: map['username'],
      text: map['text'],
      date: map['date'],
    );
  }
}
