import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:flutter_sample/favorites/bloc/favorites_cubit.dart';
import 'package:flutter_sample/quote/quote.dart';

//TODO comment here on binding between UI input and cubit state
//here it is done manually by using onChanged callbacks on simple textfields
//there are also librarieres that do this, e.g. reactive_forms

//TODO make submitResult an enum?

class AddFavoriteState extends Equatable {
  final bool submitInProgress;
  final bool? submitResult;

  final String quote;
  final String author;
  final List<String> tags;

  const AddFavoriteState({
    required this.submitInProgress,
    required this.submitResult,
    this.quote = '',
    this.author = '',
    this.tags = const [],
  });
  
  @override
  List<Object?> get props => [submitInProgress, submitResult, quote, author, tags];

  AddFavoriteState copyWith({
    bool? submitInProgress,
    bool? submitResult,
    String? quote,
    String? author,
    List<String>? tags,
  }) {
    return AddFavoriteState(
      submitInProgress: submitInProgress ?? this.submitInProgress,
      submitResult: submitResult ?? this.submitResult,
      quote: quote ?? this.quote,
      author: author ?? this.author,
      tags: tags ?? this.tags,
    );
  }
}

class AddFavoriteCubit extends Cubit<AddFavoriteState> {
  final FavoritesCubit favoritesCubit;

  AddFavoriteCubit({
    required this.favoritesCubit,
  }) : 
    super(const AddFavoriteState(
      submitInProgress: false,
      submitResult: null
    ));

  Future<bool> submit() async {
    if(state.submitInProgress) {
      return false;
    }
    var quote = state.quote;
    var author = state.author;
    if(quote.isEmpty || author.isEmpty) {
      return false;
    }

    emit(state.copyWith(submitInProgress: true, submitResult: null));

    var q = Quote(
      text: quote,
      author: author,
      source: 'me',
      tags: state.tags,
    );

    var success = await favoritesCubit.add(q);
    if(success) {
      emit(state.copyWith(submitInProgress: false, submitResult: true));
      return true;
    } else {
      emit(state.copyWith(submitInProgress: false, submitResult: false));
      return false;
    }
  }

  void setQuote(String quote) {
    emit(state.copyWith(quote: quote));
  }

  void setAuthor(String author) {
    emit(state.copyWith(author: author));
  }

  void addTag(String tag) {
    if(!state.tags.contains(tag)) {
      var tags = List<String>.from(state.tags)..add(tag);
      emit(state.copyWith(tags: tags));
    }
  }

  void removeTag(String tag) {
    if(state.tags.contains(tag)) {
      var tags = state.tags.where((t) => t != tag).toList();
      emit(state.copyWith(tags: tags));
    }
  }
}