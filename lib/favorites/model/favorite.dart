import 'package:equatable/equatable.dart';
import 'package:flutter_quotes/util/time.dart';
import 'package:flutter_quotes/quote/model/quote.dart';

class Favorite extends Equatable {
  String get id => quote.id;
  final Quote quote;
  final DateTime timeAdded;

  const Favorite({
    required this.quote,
    required this.timeAdded,
  });

  factory Favorite.fromQuote({
    required Quote quote,
    DateTime? timeAdded,
  }) {
    var ta = timeAdded ?? currentTime();
    return Favorite(
      quote: quote,
      timeAdded: ta,
    );
  }

  @override
  List<Object?> get props => [quote, timeAdded];

  Map<String, dynamic> toMap() {
    return {
      'quote': quote.toMap(),
      'timeAdded': timeAdded.millisecondsSinceEpoch,
    };
  }

  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      quote: Quote.fromMap(map['quote']),
      timeAdded: DateTime.fromMillisecondsSinceEpoch(map['timeAdded']),
    );
  }
}
