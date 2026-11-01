import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mygarage/core/database/app_database.dart';
import 'package:mygarage/core/database/database_provider.dart';
import 'package:mygarage/main.dart';

void main() {
  testWidgets('MyGarageApp launches and displays Home screen and navigation', (WidgetTester tester) async {
    final testDb = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(testDb),
        ],
        child: const MyGarageApp(),
      ),
    );

    // Initial pump
    await tester.pumpAndSettle();

    // Verify Title & Vehicle
    expect(find.text('MyGarage'), findsOneWidget);
    expect(find.text('MG Comet EV'), findsOneWidget);

    // Verify Navigation Bar Destinations
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Vehicle'), findsOneWidget);
    expect(find.text('Issues'), findsOneWidget);
    expect(find.text('Service'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Verify Action Button
    expect(find.text('Report Issue'), findsOneWidget);

    await testDb.close();
  });
}
