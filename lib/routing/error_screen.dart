import 'package:flutter/material.dart';
import 'package:flutter_quotes/theme/theme.dart';
import 'package:flutter_quotes/routing/routing.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isMobile = context.layout == Layout.mobile;
    var padding = isMobile ? context.insets.paddingM : context.insets.paddingL;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: padding,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error, size: context.sizes.scaled(128.0)),
                  SizedBox(
                    height: context.sizes.spaceM,
                  ),
                  Text(
                    'Ups, this page doesn\'t exist.',
                    style: context.theme.textTheme.titleLarge,
                  ),
                  SizedBox(
                    height: context.sizes.spaceM,
                  ),
                  ElevatedButton(
                    onPressed: () => context.go(const LoginRoute()),
                    child: const Text('Back'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
