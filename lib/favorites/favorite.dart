import 'package:equatable/equatable.dart';
import 'package:flutter_sample/quote/quote.dart';

class Favorite extends Equatable {
  final String id;
  final Quote quote;
  final DateTime timeAdded;

  const Favorite({
    required this.id,
    required this.quote,
    required this.timeAdded,
  });
  
  @override
  List<Object?> get props => [quote, timeAdded];
}