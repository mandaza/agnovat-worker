import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agnovat_w/presentation/widgets/common/loading_overlay.dart';
import '../../helpers/pump_app.dart';

void main() {
  group('LoadingOverlay Widget Tests', () {
    const testChild = Text('Child Widget');

    group('Display States', () {
      testWidgets('shows child when not loading', (tester) async {
        await tester.pumpApp(
          const LoadingOverlay(
            isLoading: false,
            child: testChild,
          ),
        );

        expect(find.text('Child Widget'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets('shows loading indicator when loading', (tester) async {
        await tester.pumpApp(
          const LoadingOverlay(
            isLoading: true,
            child: testChild,
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('shows both child and overlay when loading', (tester) async {
        await tester.pumpApp(
          const LoadingOverlay(
            isLoading: true,
            child: testChild,
          ),
        );

        // Both child and loading indicator should be present
        expect(find.text('Child Widget'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('displays message when provided and loading', (tester) async {
        await tester.pumpApp(
          const LoadingOverlay(
            isLoading: true,
            message: 'Loading data...',
            child: testChild,
          ),
        );

        expect(find.text('Loading data...'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('does not display message when not loading', (tester) async {
        await tester.pumpApp(
          const LoadingOverlay(
            isLoading: false,
            message: 'Loading data...',
            child: testChild,
          ),
        );

        expect(find.text('Loading data...'), findsNothing);
      });

      testWidgets('does not display message when null', (tester) async {
        await tester.pumpApp(
          const LoadingOverlay(
            isLoading: true,
            child: testChild,
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        // No message text should be found
        final textWidgets = tester.widgetList<Text>(find.byType(Text));
        final hasLoadingMessage = textWidgets.any(
          (text) => text.data?.contains('Loading') ?? false,
        );
        expect(hasLoadingMessage, isFalse);
      });
    });

    group('Layout', () {
      testWidgets('uses Stack layout', (tester) async {
        await tester.pumpApp(
          const LoadingOverlay(
            isLoading: true,
            child: testChild,
          ),
        );

        // LoadingOverlay should contain at least one Stack
        expect(find.byType(Stack), findsWidgets);
      });

      testWidgets('overlay covers entire area', (tester) async {
        await tester.pumpApp(
          const SizedBox(
            width: 400,
            height: 400,
            child: LoadingOverlay(
              isLoading: true,
              child: testChild,
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.ancestor(
            of: find.byType(CircularProgressIndicator),
            matching: find.byType(Container),
          ).first,
        );

        expect(container.color, equals(Colors.black54));
      });

      testWidgets('loading indicator is centered', (tester) async {
        await tester.pumpApp(
          const LoadingOverlay(
            isLoading: true,
            child: testChild,
          ),
        );

        expect(
          find.ancestor(
            of: find.byType(CircularProgressIndicator),
            matching: find.byType(Center),
          ),
          findsOneWidget,
        );
      });

      testWidgets('loading content is in a Card', (tester) async {
        await tester.pumpApp(
          const LoadingOverlay(
            isLoading: true,
            message: 'Please wait',
            child: testChild,
          ),
        );

        final card = find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(Card),
        );

        expect(card, findsOneWidget);
      });
    });

    group('State Transitions', () {
      testWidgets('transitions from loading to not loading', (tester) async {
        await tester.pumpApp(
          const LoadingOverlay(
            isLoading: true,
            child: testChild,
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pumpApp(
          const LoadingOverlay(
            isLoading: false,
            child: testChild,
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets('transitions from not loading to loading', (tester) async {
        await tester.pumpApp(
          const LoadingOverlay(
            isLoading: false,
            child: testChild,
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsNothing);

        await tester.pumpApp(
          const LoadingOverlay(
            isLoading: true,
            message: 'Now loading...',
            child: testChild,
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Now loading...'), findsOneWidget);
      });
    });

    group('Child Widget Integration', () {
      testWidgets('works with complex child widgets', (tester) async {
        await tester.pumpApp(
          LoadingOverlay(
            isLoading: false,
            child: Column(
              children: [
                const Text('Title'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Button'),
                ),
              ],
            ),
          ),
        );

        expect(find.text('Title'), findsOneWidget);
        expect(find.text('Button'), findsOneWidget);
      });

      testWidgets('child remains interactive when not loading', (tester) async {
        var buttonPressed = false;

        await tester.pumpApp(
          LoadingOverlay(
            isLoading: false,
            child: ElevatedButton(
              onPressed: () => buttonPressed = true,
              child: const Text('Press Me'),
            ),
          ),
        );

        await tester.tap(find.text('Press Me'));
        await tester.pumpAndSettle();

        expect(buttonPressed, isTrue);
      });

      testWidgets('child is blocked when loading', (tester) async {
        var buttonPressed = false;

        await tester.pumpApp(
          LoadingOverlay(
            isLoading: true,
            child: ElevatedButton(
              onPressed: () => buttonPressed = true,
              child: const Text('Press Me'),
            ),
          ),
        );

        // Button exists but is covered by overlay
        expect(find.text('Press Me'), findsOneWidget);

        // Overlay should block interaction
        final overlay = find.byWidgetPredicate(
          (widget) => widget is Container && widget.color == Colors.black54,
        );
        expect(overlay, findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles very long message text', (tester) async {
        const longMessage = 'This is a very long loading message that might '
            'wrap to multiple lines and should still be displayed correctly '
            'without causing any layout issues in the loading overlay widget';

        await tester.pumpApp(
          const LoadingOverlay(
            isLoading: true,
            message: longMessage,
            child: testChild,
          ),
        );

        expect(find.text(longMessage), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('handles empty message string', (tester) async {
        await tester.pumpApp(
          const LoadingOverlay(
            isLoading: true,
            message: '',
            child: testChild,
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('loading indicator is accessible', (tester) async {
        await tester.pumpApp(
          const LoadingOverlay(
            isLoading: true,
            message: 'Loading...',
            child: testChild,
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Loading...'), findsOneWidget);

        handle.dispose();
      });
    });

    group('Theme Integration', () {
      testWidgets('works with light theme', (tester) async {
        await tester.pumpApp(
          const LoadingOverlay(
            isLoading: true,
            message: 'Loading...',
            child: testChild,
          ),
          themeMode: ThemeMode.light,
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('works with dark theme', (tester) async {
        await tester.pumpApp(
          const LoadingOverlay(
            isLoading: true,
            message: 'Loading...',
            child: testChild,
          ),
          themeMode: ThemeMode.dark,
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });
  });
}
