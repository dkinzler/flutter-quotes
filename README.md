# Flutter Quotes

A sample app for browsing quotes, intended to showcase Flutter development features and best practices.
[Test the app live in your browser.](https://d39b.github.io/flutter-quotes/web)

* State-management using the [bloc library](https://pub.dev/packages/bloc)
* Adaptive and responsive UI
* Testing: unit, widget and integration tests
* Performance profiling

The source code of the app is organized by feature, e.g. the code for the search and favorites feature can be found in the folders `lib/search` and `lib/favorites` respectively.

<br>  

## Documentation

Explanations about the architecture, design decisions and workings of certain features of the app can be found throughout the comments in the source code.
Here are some pointers:

* State management using Blocs/Cubits for more complex features like search and favorites 
  * [lib/search/search_cubit.dart]
  * [lib/favorites/bloc/favorites_cubit.dart]
  * [lib/favorites/filter/filter_bloc.dart]
* Routing [lib/routing/router.dart]
* Implementing user interaction using Intents and Actions [lib/search/actions.dart]
* Using a Bloc to track metrics/analytics [lib/tips/bloc/bloc.dart]
* Theming, keeping the UI consistent across features and making it easier to change [lib/theme/app_theme.dart]
* Logging [lib/logging.dart]
* Supporting additional quote APIs [lib/quote/provider.dart]
* Integration testing [integration_test/integration_test.dart]
* Unit testing Blocs/Cubits [test/auth/login/login_cubit_test.dart]
* Widget testing the interplay between state components (e.g. Blocs/Cubits) and widgets/UI [test/favorites/ui/favorites_list_test.dart]


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

To collect performance statistics, run a performance test in profile mode:

```shell
flutter drive \
 --driver=test_driver/performance_test.dart \
 --target=integration_test/performance_test.dart \
 --profile
```

A summary report, that includes e.g. the average frame build time, will be output to the file `performance_summary.json`.

## Todos

There are still many possibilities to improve this app

* increase test coverage
* make folder structure more consistent

## License

[MIT](LICENSE)