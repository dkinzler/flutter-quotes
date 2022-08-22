import 'package:flutter/material.dart';
import 'package:flutter_quotes/home/actions.dart';
import 'package:flutter_quotes/keys.dart';
import 'package:flutter_quotes/theme/theme.dart';

class CustomAppBar extends AppBar {
  CustomAppBar({Key? key})
      : super(
            key: key,
            title: const Text('Flutter Quotes'),
            centerTitle: true,
            actions: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: AppBarPopupMenu(
                  key: ValueKey(AppKey.appbarPopupMenu),
                ),
              )
            ]);
}

enum AppBarMenu { settings, logout }

class AppBarPopupMenu extends StatelessWidget {
  const AppBarPopupMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppBarMenu>(
      icon: const Icon(Icons.menu),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            key: const ValueKey(AppKey.appbarSettingsButton),
            value: AppBarMenu.settings,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.settings),
                SizedBox(width: context.sizes.spaceS),
                const Text('Settings'),
              ],
            ),
          ),
          PopupMenuItem(
            key: const ValueKey(AppKey.appbarLogoutButton),
            value: AppBarMenu.logout,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.logout),
                SizedBox(width: context.sizes.spaceS),
                const Text('Logout'),
              ],
            ),
          ),
        ];
      },
      onSelected: (AppBarMenu value) {
        if (value == AppBarMenu.settings) {
          Actions.invoke<OpenSettingsIntent>(
              context, const OpenSettingsIntent());
        } else {
          Actions.invoke<LogoutIntent>(context, const LogoutIntent());
        }
      },
    );
  }
}
