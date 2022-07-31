import 'package:flutter/material.dart';
import 'package:flutter_sample/auth/auth_cubit.dart';
import 'package:flutter_sample/routing/routing.dart';

class LogoutIntent extends Intent {
  const LogoutIntent();
}

class LogoutAction extends ContextAction<LogoutIntent> {
  final AuthCubit authCubit;

  LogoutAction({required this.authCubit});

  @override
  void invoke(LogoutIntent intent, [BuildContext? context]) {
    if (context == null) {
      return;
    }
    showDialog(
        context: context,
        barrierColor: Colors.black87,
        builder: (context) {
          return AlertDialog(
            content: const Text('Do you really want to logout?'),
            actionsPadding: const EdgeInsets.all(8.0),
            actions: [
              ElevatedButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: const Text('Logout'),
                onPressed: () {
                  authCubit.logout();
                },
              ),
            ],
          );
        });
  }
}

class OpenSettingsIntent extends Intent {
  const OpenSettingsIntent();
}

class OpenSettingsAction extends Action<OpenSettingsIntent> {
  final AppRouter appRouter;

  OpenSettingsAction({required this.appRouter});

  @override
  void invoke(OpenSettingsIntent intent) {
    appRouter.push(const SettingsRoute());
  }
}
