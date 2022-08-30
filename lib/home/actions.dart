import 'package:flutter/material.dart';
import 'package:flutter_quotes/auth/repository/repository.dart';
import 'package:flutter_quotes/keys.dart';
import 'package:flutter_quotes/routing/routing.dart';
import 'package:provider/provider.dart';

/*
See lib/search/actions.dart for an explanation of how intents and actions work and why we use them in this app.
*/

class LogoutIntent extends Intent {
  const LogoutIntent();
}

class LogoutAction extends ContextAction<LogoutIntent> {
  final AuthRepository authRepository;

  LogoutAction({required this.authRepository});

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
                key: const ValueKey(AppKey.logoutConfirmDialogCancelButton),
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                key: const ValueKey(AppKey.logoutConfirmDialogConfirmButton),
                child: const Text('Logout'),
                onPressed: () {
                  authRepository.logout();
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

Map<Type, Action<Intent>> getHomeActions(BuildContext context) {
  return <Type, Action<Intent>>{
    LogoutIntent: LogoutAction(
      authRepository: context.read<AuthRepository>(),
    ),
    OpenSettingsIntent: OpenSettingsAction(
      appRouter: context.read<AppRouter>(),
    )
  };
}
