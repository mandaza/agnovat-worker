// Basic widget test for Agnovat app

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agnovat_w/app.dart';

void main() {
  testWidgets('Sign in screen displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: AgnovatApp(),
      ),
    );

    // Verify that the sign in screen appears (not authenticated)
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in to continue to Agnovat'), findsOneWidget);

    // Verify email and password fields exist
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Verify sign in button exists
    expect(find.text('Sign In'), findsOneWidget);
  });
}
