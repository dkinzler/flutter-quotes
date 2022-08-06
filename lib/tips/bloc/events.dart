import 'package:equatable/equatable.dart';
import 'package:flutter_sample/tips/bloc/state.dart';

abstract class TipEvent extends Equatable {
  const TipEvent();

  @override
  List<Object?> get props => const [];
}

class TipOpened extends TipEvent {
  final Tip tip;

  //whether or not the tip was opened automatically or by the user
  final bool openedAutomatically;

  const TipOpened({
    required this.tip,
    this.openedAutomatically = false,
  });
}

class TipClosed extends TipEvent {
  final Tip tip;

  const TipClosed({
    required this.tip,
  });
}

class TipSettingsChanged extends TipEvent {
  final bool? showTips;

  const TipSettingsChanged({
    this.showTips,
  });
}
