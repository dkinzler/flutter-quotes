//use these values when passing a ValueKey to a widget
//using these constants is less error prone than using strings directly
//e.g. we don't have to worry about typos when we need a key in a test
//if we were to use strings in ValueKeys, e.g. ValueKey('loginButton')
//then we need to type 'loginButton' again in test files and a typo does not produce a compile-time error

enum AppKey {
  loginEmailTextField,
  loginPasswordTextField,
  loginButton,
}
