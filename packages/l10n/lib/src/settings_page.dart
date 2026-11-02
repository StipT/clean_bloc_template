import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:l10n/src/generated/app_localizations.dart';
import 'package:l10n/src/locale_cubit.dart';
import 'package:l10n/src/theme_cubit.dart';

/// Page to switch language and theme. Needs [LocaleCubit] and [ThemeCubit]
/// above it in the tree.
class SettingsPage extends StatelessWidget {
  /// Creates the settings page.
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = context.watch<LocaleCubit>().state;
    final themeMode = context.watch<ThemeCubit>().state;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          ListTile(title: Text(l10n.languageLabel)),
          RadioGroup<Locale?>(
            groupValue: locale,
            onChanged: context.read<LocaleCubit>().setLocale,
            child: Column(
              children: [
                RadioListTile<Locale?>(
                  value: null,
                  title: Text(l10n.languageSystem),
                ),
                RadioListTile<Locale?>(
                  value: const Locale('en'),
                  title: Text(l10n.languageEnglish),
                ),
                RadioListTile<Locale?>(
                  value: const Locale('hr'),
                  title: Text(l10n.languageCroatian),
                ),
              ],
            ),
          ),
          ListTile(title: Text(l10n.themeLabel)),
          RadioGroup<ThemeMode>(
            groupValue: themeMode,
            onChanged: (mode) {
              if (mode != null)
                unawaited(context.read<ThemeCubit>().setThemeMode(mode));
            },
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  title: Text(l10n.themeSystem),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  title: Text(l10n.themeLight),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  title: Text(l10n.themeDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
