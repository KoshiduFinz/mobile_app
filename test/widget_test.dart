import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agasthi_mobile/main.dart';

void main() {
  testWidgets('Home screen displays welcome message', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AgasthiApp());

    // Verify that the welcome message is displayed.
    expect(find.text('Welcome to Agasthi Mobile'), findsOneWidget);
    expect(find.text('Android version ready for development'), findsOneWidget);
    expect(find.byIcon(Icons.phone_android), findsOneWidget);
  });
}
