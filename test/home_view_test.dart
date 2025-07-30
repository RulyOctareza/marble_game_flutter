import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:marble_game/main.dart';

void main() {
  group('Marble Game Widget Tests', () {
    testWidgets('Instruction text is present', (WidgetTester tester) async {
      await tester.pumpWidget(const MainApp());
      expect(
        find.textContaining(
          'Find the result of the division',
          findRichText: true,
        ),
        findsOneWidget,
      );
    });
  });
}
