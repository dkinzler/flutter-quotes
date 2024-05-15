# Flutter Quotes

A sample app for browsing quotes, intended to explore Flutter app development and learn how to implement common features.
[Test the app live in your browser.](https://dkinzler.github.io/flutter-quotes/web)

https://user-images.githubusercontent.com/15326809/198375308-5efdb227-91cb-4741-8a83-e047f02a6bec.mp4

* State management using the [bloc library](https://pub.dev/packages/bloc)
* Declarative routing using the [go_router package](https://pub.dev/packages/go_router)
* Communicating with backend services/APIs, storing data locally, authentication
* Logging, error collection and reporting
* Building adaptive and responsive UIs, extended theming to produce consistent app styles
* Unit, widget and integration tests
* Performance profiling

Note
* Things move fast, by the time you read this packages might be outdated, new approaches or tools to common problems like state management, routing or testing might exist etc.
* This app is intended to explore the possibilities of Flutter, many features could have been implemented in a more simple or straightforward way.

## Documentation

Comments throughout the source code explain the architecture of the app, design decisions and how to solve common problems.

* [Architecture of the app](lib/app_controller.dart)
* State management using Blocs/Cubits
   [1](lib/search/cubit/search_cubit.dart) 
   [2](lib/favorites/cubit/favorites_cubit.dart)
   [3](lib/favorites/filter/filter_bloc.dart)
* [Routing](lib/routing/router.dart)
* [Implementing user interaction using Intents and Actions](lib/search/widgets/actions.dart)
* [Using a Bloc to track metrics/analytics](lib/tips/bloc/bloc.dart)
* [Theming, keeping the UI consistent across features](lib/theme/app_theme.dart)
* [Logging](lib/logging.dart)
* [Integration testing](integration_test/integration_test.dart)
* [Unit testing Blocs/Cubits](test/auth/login/login_cubit_test.dart)

## Testing

Run unit and widget tests:

```shell
flutter test -r expanded
```

Run integration tests:

```shell
flutter drive \
 --driver=test_driver/integration_test.dart \
 --target=integration_test/integration_test.dart
```

## Performance Profiling

To collect performance metrics, run a performance test in profile mode:

```shell
flutter drive \
 --driver=test_driver/performance_test.dart \
 --target=integration_test/performance_test.dart \
 --profile
```

A summary report, that includes among other metrics the average frame build time, will be output to the file `performance_summary.json`.

## Todos

* improve performance
* add ability to listen to routing events, e.g. to collect analytics (see [lib/routing/router.dart](lib/routing/router.dart))
* feature: settings right now are global, not specific to each user that logs in
* feature: let users add their own quotes
* ...

## License

[MIT](LICENSE)
