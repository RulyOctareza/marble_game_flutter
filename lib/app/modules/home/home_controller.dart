import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marble_game/app/data/models/marble_model.dart';
import 'package:marble_game/app/data/models/math_problem_model.dart';
import 'package:marble_game/app/data/models/target_card_model.dart';

class HomeController extends GetxController {
  final GlobalKey playAreaKey = GlobalKey();
  final String title = "Marble Grouping Game";

  final problem = MathProblemModel(dividend: 24, divisor: 3);

  final RxList<MarbleModel> marbles = <MarbleModel>[].obs;
  final RxList<TargetCardModel> targetCards = <TargetCardModel>[].obs;

  void updateMarblePosition(int marbleId, Offset globalPosition) {
    final RenderBox box =
        playAreaKey.currentContext!.findRenderObject() as RenderBox;

    const double marbleSize = 40.0;

    //
    // mengubah posisi global ke posisi lokal
    //
    final Offset localPosition = box.globalToLocal(globalPosition);

    //
    // menentukan posisi X acak di dalam area permainan
    //
    final double clampedDx = localPosition.dx.clamp(
      0.0,
      box.size.width - marbleSize,
    );
    //
    // menentukan posisi Y acak di dalam area permainan
    //
    final double clampedDy = localPosition.dy.clamp(
      0.0,
      box.size.height - marbleSize,
    );

    final Offset clampedPosition = Offset(clampedDx, clampedDy);

    final int index = marbles.indexWhere((m) => m.id == marbleId);
    if (index != -1) {
      final updatedMarble = MarbleModel(
        id: marbleId,
        position: clampedPosition,
      );

      marbles[index] = updatedMarble;
    }
  }

  void addMarbleToTarget(int marbleId, int targetId) {
    final int marbleIndex = marbles.indexWhere((m) => m.id == marbleId);
    if (marbleIndex != -1) {
      final marble = marbles[marbleIndex];
      marbles.removeAt(marbleIndex);
      targetCards[targetId].marbles.add(marble);
    }
  }

  void checkAnswer() {
    final correctAnswer = problem.dividend ~/ problem.divisor;
    bool allCorrect = true;

    for (var card in targetCards) {
      if (card.marbles.length == correctAnswer) {
        card.isCorrect.value = true;
      } else {
        card.isCorrect.value = false;
        allCorrect = false;
      }
    }

    Get.dialog(
      AlertDialog(
        title: Text(allCorrect ? 'Benar!' : 'Salah!'),
        content: Text(
          allCorrect
              ? 'Selamat! Jawaban kamu benar.'
              : 'Masih ada yang salah, coba periksa lagi.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
    );
  }

  void returnMarbleToPlayArea(int marbleId, int fromCardId) {
    final card = targetCards.firstWhere((c) => c.id == fromCardId);
    final marbleIndex = card.marbles.indexWhere((m) => m.id == marbleId);

    if (marbleIndex != -1) {
      final marble = card.marbles[marbleIndex];
      card.marbles.removeAt(marbleIndex);

      // Reset position to a random one within the play area
      final RenderBox box =
          playAreaKey.currentContext!.findRenderObject() as RenderBox;
      final Random random = Random();
      final updatedMarble = MarbleModel(
        id: marble.id,
        position: Offset(
          random.nextDouble() * (box.size.width - 40),
          random.nextDouble() * (box.size.height - 40),
        ),
      );

      marbles.add(updatedMarble);
    }
  }

  @override
  void onInit() {
    super.onInit();
    initializeTargetCards();
    generateMarbles();
  }

  void initializeTargetCards() {
    targetCards.assignAll([
      TargetCardModel(id: 0, color: Colors.red),
      TargetCardModel(id: 1, color: Colors.yellow),
      TargetCardModel(id: 2, color: Colors.green),
    ]);
  }

  void generateMarbles() {
    final Size playAreaSize = Size(Get.width * 0.6, Get.height * 0.5);
    final Random random = Random();
    List<MarbleModel> newMarbles = [];

    for (int i = 0; i < problem.dividend; i++) {
      newMarbles.add(
        MarbleModel(
          id: i,
          position: Offset(
            //
            // menentukan posisi X acak di dalam area permainan
            //
            random.nextDouble() * (playAreaSize.width - 40),
            //
            // menentukan posisi Y acak di dalam area permainan
            //
            random.nextDouble() * (playAreaSize.height - 40),
          ),
        ),
      );
    }
    //
    // memasukkan semua kelereng baru ke RxList
    //
    marbles.assignAll(newMarbles);
  }
}
