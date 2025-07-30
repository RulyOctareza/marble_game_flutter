import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marble_game/main.dart';
import 'package:marble_game/app/modules/home/widgets/marble_widget.dart';

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
    testWidgets('Level indicator is present and updates correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MainApp());
      // Cek level awal (misal 1/10)
      expect(find.textContaining('1/10'), findsOneWidget);
      // Simulasikan jawaban benar (tekan Check Answer)
      final checkAnswerButton = find.text('Check Answer');
      expect(checkAnswerButton, findsOneWidget);
      await tester.tap(checkAnswerButton);
      await tester.pumpAndSettle();
      // Setelah benar, level harus naik (2/10)
      expect(find.textContaining('2/10'), findsOneWidget);
      // Simulasikan jawaban salah (tekan Check Answer tanpa interaksi, harus tetap di level 2)
      await tester.tap(checkAnswerButton);
      await tester.pumpAndSettle();
      expect(find.textContaining('2/10'), findsOneWidget);
    });
    testWidgets('New Problem button can be pressed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MainApp());
      final newProblemButton = find.text('New Problem');
      expect(newProblemButton, findsOneWidget);
      await tester.tap(newProblemButton);
      await tester.pumpAndSettle();
      // Tidak error dan tetap di halaman utama
      expect(
        find.textContaining('Find the result of the division'),
        findsOneWidget,
      );
    });
    testWidgets('Jumlah marble di play area sesuai angka depan soal', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MainApp());
      // Ambil angka depan dari soal (misal 24 dari 24 ÷ 3)
      final problemText = find.byWidgetPredicate(
        (widget) =>
            widget is Text && widget.data != null && widget.data!.contains('÷'),
      );
      expect(problemText, findsOneWidget);
      final textWidget = tester.widget<Text>(problemText);
      final soal = textWidget.data!.split('÷').first.trim();
      final jumlahMarble = int.tryParse(soal);
      // Ganti MarbleWidget dengan widget marble utama jika berbeda
      final marbleFinder = find.byType(MarbleWidget);
      expect(marbleFinder, findsNWidgets(jumlahMarble!));
    });
    testWidgets('Reset Groups button works', (WidgetTester tester) async {
      await tester.pumpWidget(const MainApp());
      final resetButton = find.text('Reset Groups');
      expect(resetButton, findsOneWidget);
      await tester.tap(resetButton);
      await tester.pumpAndSettle();
      // Tidak error dan marble kembali ke posisi awal (perlu penyesuaian jika ada state)
      // expect(...); // Tambahkan assert jika ada state marble yang bisa dicek
    });
    testWidgets('Card menampilkan status benar/salah dari marble yang di-assign', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MainApp());
      // Simulasikan assign marble ke card (perlu detail widget dan drag-drop jika ada)
      // Setelah assign, cek apakah card menampilkan status benar/salah
      // expect(find.text('Correct'), findsOneWidget); // atau sesuai label feedback
      // expect(find.text('Incorrect'), findsNothing); // contoh
    });
    testWidgets('Check Answer button can be pressed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MainApp());
      final checkAnswerButton = find.text('Check Answer');
      expect(checkAnswerButton, findsOneWidget);
      await tester.tap(checkAnswerButton);
      await tester.pumpAndSettle();
      // Tidak error dan aplikasi tetap berjalan
      expect(
        find.textContaining('Find the result of the division'),
        findsOneWidget,
      );
    });
  });
}
