import 'package:equatable/equatable.dart';

class Quote extends Equatable {
  final String text;

  final String author;
  final String? authorId;

  final List<String> tags;

  final String? id;
  final String source;

  const Quote({
    required this.text,
    required this.author,
    this.authorId,
    this.tags = const[],
    this.id,
    required this.source,
  });
  
  @override
  List<Object?> get props => [text, author, authorId, tags , id, source];

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'author': author,
      'authorId': authorId,
      'tags': tags,
      'id': id,
      'source': source,
    };
  }

  factory Quote.fromMap(Map<String, dynamic> map) {
    return Quote(
      text: map['text'] ?? '',
      author: map['author'] ?? '',
      authorId: map['authorId'],
      tags: List<String>.from(map['tags']),
      id: map['id'],
      source: map['source'] ?? '',
    );
  }
}
