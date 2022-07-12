import 'dart:convert';

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

  /*TODO remove this?
    having this caused an issue with sorting a list of Favorites (that each contain a quote)
    in FavoritesCubit, something with hashing
    the reason we had this however was that when we search for or load a random quote
    that was already added to favorites, we want this to be detected if the id's are the same
    even though the quote might have been slightly changed in the backend api
    otherwise if there was a small change the quote will not be marked as favorited
    for testing this override the onError method in the FilterCubit, otherwise
    nothing will be printed and stuff will just mysteriously fail
  @override
  bool operator ==(Object other) {
    if(other is Quote) {
      if(source == other.source && id != null && id == other.id) {
        return true;
      }
    }
    return this == other;
  }
  */

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
