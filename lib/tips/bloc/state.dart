import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';

enum Tip {
  login;

  factory Tip.fromString(String t) {
    var tip = Tip.values.firstWhereOrNull((e) => e.name == t);
    if (tip == null) {
      //this shouldn't happen, probably a bug
      throw Exception('no Tip element found for string: $t');
    }
    return tip;
  }
}

class TipsState extends Equatable {
  //if true, tips will be shown automatically the first time the user encounters the particular page/screen
  //set to false to never automatically show tips
  final bool showTips;

  //the set of tips the user has already seen
  //these will not be shown automatically again
  final Set<Tip> seenTips;

  //the last time a given Tip was opened
  //this is used to calculate analytics, e.g. how long a tip has been shown to a user
  //since this data is not really useful between app restarts, we don't need to persist it
  //and therefore it is not included in the toMap() function
  final Map<Tip, DateTime> timeOpened;

  const TipsState({
    this.showTips = true,
    this.seenTips = const {},
    this.timeOpened = const {},
  });

  @override
  List<Object?> get props => [showTips, seenTips, timeOpened];

  TipsState copyWith({
    bool? showTips,
    Set<Tip>? seenTips,
    Map<Tip, DateTime>? timeOpened,
  }) {
    return TipsState(
      showTips: showTips ?? this.showTips,
      seenTips: seenTips ?? this.seenTips,
      timeOpened: timeOpened ?? this.timeOpened,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'showTips': showTips,
      'seenTips': seenTips.map((x) => x.name).toList(),
    };
  }

  factory TipsState.fromMap(Map<String, dynamic> map) {
    return TipsState(
      showTips: map['showTips'] ?? false,
      seenTips: Set<Tip>.from(
          map['seenTips']?.map((x) => Tip.fromString(x)) ?? <Tip>[]),
    );
  }
}
