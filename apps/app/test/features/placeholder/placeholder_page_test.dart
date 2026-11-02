import 'package:flutter_bloc_template/app.dart';
import 'package:flutter_bloc_template/features/placeholder/placeholder_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App shows the placeholder page with its title', (tester) async {
    await tester.pumpWidget(const App());

    expect(find.byType(PlaceholderPage), findsOneWidget);
    expect(find.text('Flutter BLoC Template'), findsOneWidget);
  });
}
