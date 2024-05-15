import 'package:flutter_quotes/tips/bloc/events.dart';
import 'package:flutter_quotes/tips/bloc/state.dart';
import 'package:flutter_quotes/util/time.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:logging/logging.dart';

/*
TipsBloc keeps track of the settings for showing tips automatically to users and which tips a user has already seen.
We use a bloc here that accepts 3 different events:
- TipOpened: should be added by the app when a tip dialog is shown, either automatically or initiated by the user e.g. by clicking a button
- TipClosed: should be added by the app when a tip dialog is closed
- TipSettingsChanged: can be added to change the behavior of the tip system, e.g. set whether or not tips should be shown automatically the first time a user sees a certain app page/screen

Using the events we can track user behavior and calculate metrics/analytics, 
e.g. are users actually using the tips and if yes how long are the looking at them.

The same approach to collecting metrics could be used for any other feature/part of the app.
*/

class TipsBloc extends HydratedBloc<TipEvent, TipsState> {
  final _log = Logger('TipBloc');

  // HydratedBloc will only use the state passed to super if no state was previously stored
  // the previous state will be loaded synchronously in the constructor
  // so we don't need to worry that there is a small period on app startup where the stored state is not available
  TipsBloc() : super(const TipsState()) {
    on<TipOpened>(_onTipOpened);
    on<TipClosed>(_onTipClosed);
    on<TipSettingsChanged>(_onTipSettingsChanged);
  }

  void _onTipOpened(TipOpened event, Emitter emit) {
    var seenTips = Set<Tip>.from(state.seenTips)..add(event.tip);

    var timeOpened = Map<Tip, DateTime>.from(state.timeOpened);
    timeOpened[event.tip] = currentTime();

    emit(state.copyWith(
      seenTips: seenTips,
      timeOpened: timeOpened,
    ));
  }

  void _onTipClosed(TipClosed event, Emitter emit) {
    // calculate the time the dialog was opened
    // here we only log this information to console
    // in an actual app we might e.g. sent this data to an analytics service like Google Analytics
    // using this information we could e.g. infer whether or not users are actually reading the tips
    // if the duration the dialog was open is very small, the user probably just closed the dialog and didn't even read it
    var timeClosed = currentTime();
    var timeOpened = state.timeOpened[event.tip];
    if (timeOpened != null) {
      var duration = timeClosed.difference(timeOpened);
      _log.info('${event.tip} tip was open for $duration');
    }
  }

  void _onTipSettingsChanged(TipSettingsChanged event, Emitter emit) {
    var showTips = event.showTips;
    if (showTips != null && showTips != state.showTips) {
      emit(state.copyWith(showTips: showTips));
    }
  }

  bool shouldAutomaticallyShowTip(Tip tip) {
    if (!state.showTips) {
      return false;
    }
    return !state.seenTips.contains(tip);
  }

  @override
  TipsState? fromJson(Map<String, dynamic> json) {
    return TipsState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(TipsState state) {
    return state.toMap();
  }
}
