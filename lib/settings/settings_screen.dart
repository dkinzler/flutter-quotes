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
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Padding(
        padding: context.insets.paddingL,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600,
            ),
            child: Card(
              elevation: 8.0,
              //TODO can wrap this in SingleChildScrollView to be safe
              //should normally work, maybe not on a smaller phone in landscape mode
              child: Padding(
                padding: context.insets.symmetricScaled(
                  horizontal: 8.0,
                  vertical: 16.0,
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Dark mode'),
                      secondary: const Icon(Icons.color_lens),
                      value: settings.darkMode,
                      onChanged: (value) {
                        context.read<SettingsCubit>().setDarkMode(value);
                      },
                    ),
                    const Divider(),
                    const QuoteProviderSelectionTile(),
                    const Divider(),
                    const AboutListTile(
                      icon: Icon(Icons.info),
                      applicationName: 'Flutter Quotes',
                      applicationVersion: '1.0',
                      child: Text('About this app'),
                    ),
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

class QuoteProviderSelectionTile extends StatelessWidget {
  const QuoteProviderSelectionTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var currentQuoteProvider = context
        .select<SettingsCubit, QuoteProvider>((c) => c.state.quoteProvider);
    return ExpansionTile(
      leading: const Icon(Icons.api),
      title: const Text('Select quote provider API'),
      children: QuoteProvider.values
          .map<Widget>((quoteProvider) => RadioListTile<QuoteProvider>(
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

  String quoteProviderToName(QuoteProvider quoteProvider) {
    if (quoteProvider == QuoteProvider.mock) {
      return 'Mock';
    } else {
      return 'Quotable (api.quotable.io)';
    }
  }
}
