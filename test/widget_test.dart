import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ankipush/core/di/injection_container.dart';
import 'package:ankipush/main.dart';

void main() {
  setUp(() async {
    await sl.reset();
    await initDependencies();
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('AnkiPushApp initial layout smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AnkiPushApp());
    await tester.pumpAndSettle();

    // Verify AppBar title
    expect(find.text('AnkiPush'), findsOneWidget);

    // Verify language indicator
    expect(find.text('🇩🇪 DE'), findsOneWidget);
    expect(find.text('🇷🇺 RU'), findsOneWidget);

    // Verify input field and search button
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Найти'), findsOneWidget);

    // Verify initial suggestions guidance card
    expect(find.text('Поиск и создание карточек'), findsOneWidget);
    expect(find.text('Apfel'), findsOneWidget);

    // Verify bottom action button exists and is disabled
    final actionButton = find.text('Добавить в Anki');
    expect(actionButton, findsOneWidget);

    final elevatedButton = tester.widget<ElevatedButton>(
      find.ancestor(
        of: actionButton,
        matching: find.byType(ElevatedButton),
      ),
    );
    expect(elevatedButton.onPressed, isNull);
  });
}
