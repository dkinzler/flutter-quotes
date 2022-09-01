import 'package:equatable/equatable.dart';
import 'package:flutter_quotes/quote/model/quote.dart';

/*
A quote as returned by the Quotable API.
*/
class QuotableQuote extends Equatable {
  final String id;
  final String content;
  final String author;
  final String authorSlug;
  final int length;
  final List<String> tags;

  const QuotableQuote(
      {required this.id,
      required this.content,
      required this.author,
      required this.authorSlug,
      required this.length,
      required this.tags});

  @override
  List<Object?> get props => [id, content, author, authorSlug, length, tags];

  Quote toQuote() {
    return Quote(
      text: content,
      author: author,
      authorId: authorSlug,
      tags: tags,
      sourceId: id,
      source: 'api.quotable.io',
    );
  }

  factory QuotableQuote.fromMap(Map<String, dynamic> map) {
    return QuotableQuote(
      id: map['_id'] ?? '',
      content: map['content'] ?? '',
      author: map['author'] ?? '',
      authorSlug: map['authorSlug'] ?? '',
      length: map['length']?.toInt() ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
    );
  }
}
