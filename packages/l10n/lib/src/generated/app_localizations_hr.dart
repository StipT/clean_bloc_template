// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Croatian (`hr`).
class AppLocalizationsHr extends AppLocalizations {
  AppLocalizationsHr([String locale = 'hr']) : super(locale);

  @override
  String get settingsTitle => 'Postavke';

  @override
  String get languageLabel => 'Jezik';

  @override
  String get languageSystem => 'Zadano sustava';

  @override
  String get languageEnglish => 'Engleski';

  @override
  String get languageCroatian => 'Hrvatski';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeSystem => 'Sustav';

  @override
  String get themeLight => 'Svijetla';

  @override
  String get themeDark => 'Tamna';

  @override
  String get postsTitle => 'Objave';

  @override
  String get postsEmpty => 'Još nema objava';

  @override
  String get errorGeneric => 'Nešto je pošlo po zlu';

  @override
  String get retryLabel => 'Pokušaj ponovno';

  @override
  String get appTitle => 'Flutter BLoC predložak';
}
