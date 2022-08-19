import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quotes/auth/auth_cubit.dart';
import 'package:flutter_quotes/quote/provider.dart';
import 'package:flutter_quotes/settings/settings_cubit.dart';
import 'package:flutter_quotes/theme/theme.dart';
import 'package:flutter_quotes/tips/bloc/bloc.dart';
import 'package:flutter_quotes/tips/bloc/events.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //use smaller padding on mobile
    var isMobile = context.layout == Layout.mobile;
    var padding = isMobile ? context.insets.paddingM : context.insets.paddingL;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Padding(
        padding: padding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600,
            ),
            child: Card(
              elevation: 8.0,
              child: Padding(
                padding: context.insets.symmetricScaled(
                  horizontal: 8.0,
                  vertical: 16.0,
                ),
                //use a ListView since contents might not fit on screen, especially on smaller devices and when some of the tiles are expanded
                child: ListView(
                  children: const [
                    MyAccountTile(),
                    Divider(),
                    DarkModeSwitchListTile(),
                    Divider(),
                    UIScaleSliderTile(),
                    Divider(),
                    QuoteProviderSelectionTile(),
                    Divider(),
                    AboutListTile(
                      icon: Icon(Icons.info),
                      applicationName: 'Flutter Quotes',
                      applicationVersion: '1.0',
                      child: Text('About this app'),
                    ),
                    Divider(),
                    TipsSwitchListTile(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DarkModeSwitchListTile extends StatelessWidget {
  const DarkModeSwitchListTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var settings = context.watch<SettingsCubit>().state;
    return SwitchListTile(
      title: const Text('Dark mode'),
      secondary: const Icon(Icons.color_lens),
      value: settings.darkMode,
      onChanged: (value) {
        context.read<SettingsCubit>().setDarkMode(value);
      },
    );
  }
}

class QuoteProviderSelectionTile extends StatelessWidget {
  const QuoteProviderSelectionTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var currentQuoteProvider = context
        .select<SettingsCubit, QuoteProviderType>((c) => c.state.quoteProvider);
    return ExpansionTile(
      leading: const Icon(Icons.api),
      title: const Text('Select quote provider API'),
      children: QuoteProviderType.values
          .map<Widget>((quoteProvider) => RadioListTile<QuoteProviderType>(
                value: quoteProvider,
                groupValue: currentQuoteProvider,
                title: Text(quoteProviderToName(quoteProvider)),
                onChanged: (qp) {
                  if (qp != null) {
                    context.read<SettingsCubit>().setQuoteProvider(qp);
                  }
                },
              ))
          .toList(),
    );
  }

  String quoteProviderToName(QuoteProviderType quoteProvider) {
    if (quoteProvider == QuoteProviderType.mock) {
      return 'Mock';
    } else {
      return 'Quotable (api.quotable.io)';
    }
  }
}

class UIScaleSliderTile extends StatelessWidget {
  const UIScaleSliderTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        leading: const Icon(Icons.format_size),
        title: const Text('Scale UI'),
        children: [
          Builder(
            builder: (context) {
              var uiScale =
                  context.select<SettingsCubit, double>((c) => c.state.uiScale);
              return Slider(
                min: 1.0,
                max: 2.5,
                value: uiScale,
                onChanged: (value) {
                  context.read<SettingsCubit>().setUIScale(value);
                },
              );
            },
          ),
        ]);
  }
}

class MyAccountTile extends StatelessWidget {
  const MyAccountTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var authState = context.watch<AuthCubit>().state;

    List<Widget> children;
    if (authState.isAuthenticated) {
      var user = authState.user;
      children = [
        ListTile(
          title: const Text('Email'),
          subtitle: Text(user.email),
        ),
        ListTile(
          title: const Text('Name'),
          subtitle: Text(user.name),
        ),
        if (user.lastLoginTime != null)
          ListTile(
            title: const Text('Last logged in'),
            subtitle:
                Text(DateFormat.yMMMd().add_jm().format(user.lastLoginTime!)),
          ),
      ];
    } else {
      children = [const Text('Not logged in')];
    }

    return ExpansionTile(
      leading: const Icon(Icons.account_box),
      title: const Text('My Account'),
      children: children,
    );
  }
}

class TipsSwitchListTile extends StatelessWidget {
  const TipsSwitchListTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var showTips = context.watch<TipsBloc>().state.showTips;
    return SwitchListTile(
      title: const Text('Show tips'),
      secondary: const Icon(Icons.lightbulb_outline),
      value: showTips,
      onChanged: (value) {
        context.read<TipsBloc>().add(TipSettingsChanged(showTips: value));
      },
    );
  }
}
