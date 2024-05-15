import 'package:equatable/equatable.dart';

class Quote extends Equatable {
  final String text;

  final String author;
  // can be null, depends on the QuoteProvider from which this quote originates
  // some quote providers assign unique author ids
  final String? authorId;

  final List<String> tags;

  // a unique string identifying the QuoteProvider from which this quote originates
  // e.g. 'quotable.io' or 'mock'
  final String source;
  // a unique id for the quote, not supported by all quote providers
  final String? sourceId;

  // if the quote provider assigned a unique id, use it
  // otherwise simply use the quote text
  String get id {
    if (sourceId != null) {
      return '$source:$sourceId';
    }
    return text;
  }

  const Quote({
    required this.text,
    required this.author,
    this.authorId,
    this.tags = const [],
    this.sourceId,
    required this.source,
  });

  @override
  List<Object?> get props => [text, author, authorId, tags, sourceId, source];

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'author': author,
      'authorId': authorId,
      'tags': tags,
      'source': source,
      'sourceId': sourceId,
    };
  }

  factory Quote.fromMap(Map<String, dynamic> map) {
    return Quote(
      text: map['text'] ?? '',
      author: map['author'] ?? '',
      authorId: map['authorId'],
      tags: List<String>.from(map['tags']),
      source: map['source'] ?? '',
      sourceId: map['sourceId'],
    );
  }
}
