import 'package:flutter/material.dart';
import 'package:flutter_quotes/keys.dart';
import 'package:flutter_quotes/tips/bloc/state.dart';
import 'package:flutter_quotes/tips/tip_button.dart';

class LoginTipButton extends StatelessWidget {
  const LoginTipButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const TipButton(
      key: ValueKey(AppKey.loginTipButton),
      tip: Tip.login,
      dialogContent: Text(
          'This is just a demo app, you can log in using any email and password combination.'),
      dialogAlignment: Alignment.center,
    );
  }
}
