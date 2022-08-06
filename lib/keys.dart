/*
Use the enum values defined here for any ValueKeys passed to widgets.
Using strings in keys (e.g. ValueKey('loginButton)) is error prone, because we would need to duplicate the string
e.g. in test files and typos will cause errors that are not detected at compile-time.
*/

enum AppKey {
  loginEmailTextField,
  loginPasswordTextField,
  loginButton,
}
