import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late LocaleCubit localeCubit;
  late ThemeCubit themeCubit;

  Future<void> pump(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    localeCubit = LocaleCubit(prefs);
    themeCubit = ThemeCubit(prefs);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: localeCubit),
          BlocProvider.value(value: themeCubit),
        ],
        child: BlocBuilder<LocaleCubit, Locale?>(
          builder: (context, locale) => MaterialApp(
            locale: locale ?? const Locale('en'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SettingsPage(),
          ),
        ),
      ),
    );
  }

  testWidgets('shows English by default', (tester) async {
    await pump(tester);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('switching language updates the page live', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Croatian'));
    await tester.pumpAndSettle();
    expect(localeCubit.state, const Locale('hr'));
    expect(find.text('Postavke'), findsOneWidget);
    await tester.tap(find.text('Zadano sustava'));
    await tester.pumpAndSettle();
    expect(localeCubit.state, isNull);
  });

  testWidgets('switching theme updates the cubit', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(themeCubit.state, ThemeMode.dark);
  });
}
