import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample/settings/settings_cubit.dart';
import 'package:flutter_sample/theme/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var settings = context.watch<SettingsCubit>().state;

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: context.insets.paddingL,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600,
          ),
          child: ListView(
            children: [
              CheckboxListTile(
                title: const Text('Dark mode'),
                value: settings.darkMode,
                onChanged: (value) {
                  if (value != null) {
                    context.read<SettingsCubit>().setDarkMode(value);
                  }
                },
              ),
              const AboutListTile(
                applicationName: 'Flutter Quotes',
                applicationVersion: '1.0',
                child: Text('About this app'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
