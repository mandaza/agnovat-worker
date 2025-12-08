import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agnovat_w/presentation/widgets/cards/client_card.dart';
import 'package:agnovat_w/data/models/client.dart';
import '../../helpers/pump_app.dart';

void main() {
  group('ClientCard Widget Tests', () {
    final testDateTime = DateTime(2024, 1, 15);

    // Create test client
    final testClient = Client(
      id: 'client_123',
      name: 'John Doe',
      dateOfBirth: '1990-05-15',
      ndisNumber: '12345678901',
      active: true,
      createdAt: testDateTime,
      updatedAt: testDateTime,
    );

    group('Rendering', () {
      testWidgets('displays client name', (tester) async {
        await tester.pumpApp(ClientCard(client: testClient));

        expect(find.text('John Doe'), findsOneWidget);
      });

      testWidgets('displays client age', (tester) async {
        await tester.pumpApp(ClientCard(client: testClient));

        // Age calculation from 1990-05-15 to now
        final expectedAge = DateTime.now().year - 1990;
        expect(find.textContaining('Age: '), findsOneWidget);
        expect(find.textContaining('$expectedAge'), findsOneWidget);
      });

      testWidgets('displays client initials in avatar', (tester) async {
        await tester.pumpApp(ClientCard(client: testClient));

        expect(find.text('JD'), findsOneWidget);
      });

      testWidgets('displays initials for single name', (tester) async {
        final singleNameClient = Client(
          id: 'client_456',
          name: 'Madonna',
          dateOfBirth: '1990-01-01',
          active: true,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        await tester.pumpApp(ClientCard(client: singleNameClient));

        expect(find.text('M'), findsOneWidget);
      });

      testWidgets('displays chevron icon', (tester) async {
        await tester.pumpApp(ClientCard(client: testClient));

        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      });

      testWidgets('displays active goals count when provided', (tester) async {
        await tester.pumpApp(
          ClientCard(
            client: testClient,
            activeGoalsCount: 3,
          ),
        );

        expect(find.text('3 active goals'), findsOneWidget);
        expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
      });

      testWidgets('uses singular "goal" for count of 1', (tester) async {
        await tester.pumpApp(
          ClientCard(
            client: testClient,
            activeGoalsCount: 1,
          ),
        );

        expect(find.text('1 active goal'), findsOneWidget);
      });

      testWidgets('does not display goals when count is null', (tester) async {
        await tester.pumpApp(ClientCard(client: testClient));

        expect(find.byIcon(Icons.flag_outlined), findsNothing);
        expect(find.textContaining('active goal'), findsNothing);
      });
    });

    group('Interactions', () {
      testWidgets('calls onTap when tapped', (tester) async {
        var tapped = false;

        await tester.pumpApp(
          ClientCard(
            client: testClient,
            onTap: () => tapped = true,
          ),
        );

        await tester.tap(find.byType(ClientCard));
        await tester.pumpAndSettle();

        expect(tapped, isTrue);
      });

      testWidgets('does not throw when onTap is null', (tester) async {
        await tester.pumpApp(ClientCard(client: testClient));

        await tester.tap(find.byType(ClientCard));
        await tester.pumpAndSettle();

        // Should not throw
        expect(true, isTrue);
      });

      testWidgets('is tappable via InkWell', (tester) async {
        await tester.pumpApp(
          ClientCard(
            client: testClient,
            onTap: () {},
          ),
        );

        expect(find.byType(InkWell), findsOneWidget);
      });
    });

    group('Layout', () {
      testWidgets('contains Card widget', (tester) async {
        await tester.pumpApp(ClientCard(client: testClient));

        expect(find.byType(Card), findsOneWidget);
      });

      testWidgets('contains CircleAvatar', (tester) async {
        await tester.pumpApp(ClientCard(client: testClient));

        expect(find.byType(CircleAvatar), findsOneWidget);
      });

      testWidgets('avatar has correct radius', (tester) async {
        await tester.pumpApp(ClientCard(client: testClient));

        final avatar = tester.widget<CircleAvatar>(
          find.byType(CircleAvatar),
        );

        expect(avatar.radius, equals(30));
      });

      testWidgets('name text has correct overflow behavior', (tester) async {
        final longNameClient = Client(
          id: 'client_long',
          name: 'This Is A Very Long Client Name That Should Be Truncated',
          dateOfBirth: '1990-01-01',
          active: true,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        await tester.pumpApp(ClientCard(client: longNameClient));

        final nameText = tester.widget<Text>(
          find.text(longNameClient.name),
        );

        expect(nameText.overflow, equals(TextOverflow.ellipsis));
      });
    });

    group('Edge Cases', () {
      testWidgets('handles empty name gracefully', (tester) async {
        final emptyNameClient = Client(
          id: 'client_empty',
          name: '',
          dateOfBirth: '1990-01-01',
          active: true,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        await tester.pumpApp(ClientCard(client: emptyNameClient));

        // Should display question mark for empty name
        expect(find.text('?'), findsOneWidget);
      });

      testWidgets('handles zero active goals', (tester) async {
        await tester.pumpApp(
          ClientCard(
            client: testClient,
            activeGoalsCount: 0,
          ),
        );

        expect(find.text('0 active goals'), findsOneWidget);
      });

      testWidgets('handles large active goals count', (tester) async {
        await tester.pumpApp(
          ClientCard(
            client: testClient,
            activeGoalsCount: 999,
          ),
        );

        expect(find.text('999 active goals'), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('is accessible for screen readers', (tester) async {
        await tester.pumpApp(ClientCard(client: testClient));

        final SemanticsHandle handle = tester.ensureSemantics();

        // Verify client name is accessible
        expect(find.text('John Doe'), findsOneWidget);

        handle.dispose();
      });

      testWidgets('has sufficient tap target size', (tester) async {
        await tester.pumpApp(
          ClientCard(
            client: testClient,
            onTap: () {},
          ),
        );

        final size = tester.getSize(find.byType(ClientCard));

        // Minimum tap target should be at least 48x48 logical pixels
        expect(size.height, greaterThanOrEqualTo(48));
      });
    });

    group('Theme Integration', () {
      testWidgets('respects theme text styles', (tester) async {
        await tester.pumpApp(
          ClientCard(client: testClient),
          themeMode: ThemeMode.light,
        );

        // Verify widget builds without theme errors
        expect(find.byType(ClientCard), findsOneWidget);
      });

      testWidgets('works in dark mode', (tester) async {
        await tester.pumpApp(
          ClientCard(client: testClient),
          themeMode: ThemeMode.dark,
        );

        expect(find.byType(ClientCard), findsOneWidget);
        expect(find.text('John Doe'), findsOneWidget);
      });
    });
  });
}
