import 'package:equatable/equatable.dart';

class Quote extends Equatable {
  final String text;

  final String author;
  final String? authorId;

  final List<String> tags;

  final String source;
  final String? sourceId;

  String get id {
    if(sourceId != null) {
      return '$source:$sourceId';
    }
    return text;
  }

  const Quote({
    required this.text,
    required this.author,
    this.authorId,
    this.tags = const[],
    this.sourceId,
    required this.source,
  });
  
  @override
  List<Object?> get props => [text, author, authorId, tags , sourceId, source];

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'author': author,
      'authorId': authorId,
      'tags': tags,
      'sourceId': sourceId,
      'source': source,
    };
  }

  factory Quote.fromMap(Map<String, dynamic> map) {
    return Quote(
      text: map['text'] ?? '',
      author: map['author'] ?? '',
      authorId: map['authorId'],
      tags: List<String>.from(map['tags']),
      sourceId: map['sourceId'],
      source: map['source'] ?? '',
    );
  }
}
