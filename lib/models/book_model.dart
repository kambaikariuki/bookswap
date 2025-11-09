class Book {
  final String id;
  final String title;
  final String author;
  final String condition;
  final String imageUrl;
  final String ownerId;
  final DateTime createdAt;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.condition,
    this.imageUrl = 'https://imgs.search.brave.com/8aa9tWcgc3eo0WJodcbWhIflYtygAsbpg2ZRwQwlGiU/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9tYXJr/ZXRwbGFjZS5jYW52/YS5jb20vRUFHQkZ2/dUdCTjAvMS8wLzEw/MDN3L2NhbnZhLXNp/bXBsZS1hbmQtbWlu/aW1hbGlzdC1zZWxm/LWhlYWxpbmctYm9v/ay1jb3Zlci1TV2xj/TDVRN0VYay5qcGc',
    required this.ownerId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'condition': condition,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Book.fromMap(Map<String, dynamic> map, String documentId) {
    return Book(
      id: documentId,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      condition: map['condition'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      ownerId: map['ownerId'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
