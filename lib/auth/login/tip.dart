import 'package:flutter/material.dart';
import 'package:flutter_sample/tips/bloc/state.dart';
import 'package:flutter_sample/tips/button.dart';

class LoginTipButton extends StatelessWidget {
  const LoginTipButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const TipButton(
      tip: Tip.login,
      dialogContent: Text(
          'This is just a demo app, you can log in using any email and password combination.'),
      dialogAlignment: Alignment.center,
    );
  }
}
