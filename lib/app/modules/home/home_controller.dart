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

  // Menggunakan .obs untuk setiap marble individual
  final marbles = <MarbleModel>[].obs;
  final targetCards = <TargetCardModel>[].obs;

  // Track if check answer has been pressed
  final hasCheckedAnswer = false.obs;

  void _updateMarbles(List<MarbleModel> updates) {
    final List<MarbleModel> newList = List.from(marbles);
    for (var update in updates) {
      final index = newList.indexWhere((m) => m.id == update.id);
      if (index != -1) {
        newList[index] = update;
      }
    }
    marbles.assignAll(newList);
  }

  // Mengelompokkan kelereng saat di-drag satu sama lain
  void groupMarbles(int draggedMarbleId, int targetMarbleId) {
    if (draggedMarbleId == targetMarbleId) return;

    final draggedMarble = marbles.firstWhere((m) => m.id == draggedMarbleId);
    final targetMarble = marbles.firstWhere((m) => m.id == targetMarbleId);

    // Jika target sudah di-lock, batalkan
    if (targetMarble.isLocked || draggedMarble.isLocked) return;

    // final correctCount = problem.dividend ~/ problem.divisor; // 24 ÷ 3 = 8

    // Tentukan group ID yang akan digunakan
    int? newGroupId;
    if (targetMarble.groupId != null) {
      newGroupId = targetMarble.groupId;
    } else if (draggedMarble.groupId != null) {
      newGroupId = draggedMarble.groupId;
    } else {
      // Generate new group ID
      newGroupId = _generateNewGroupId();
    }

    // Hitung jumlah marble yang akan ada dalam grup setelah merge
    final Set<int> marbleIdsInNewGroup = {};

    // Add target marble and its group
    if (targetMarble.groupId != null) {
      marbleIdsInNewGroup.addAll(
        marbles
            .where((m) => m.groupId == targetMarble.groupId)
            .map((m) => m.id),
      );
    } else {
      marbleIdsInNewGroup.add(targetMarble.id);
    }

    // Add dragged marble and its group
    if (draggedMarble.groupId != null) {
      marbleIdsInNewGroup.addAll(
        marbles
            .where((m) => m.groupId == draggedMarble.groupId)
            .map((m) => m.id),
      );
    } else {
      marbleIdsInNewGroup.add(draggedMarble.id);
    }

    // Jika total melebihi jawaban yang benar, batalkan
    // Tidak perlu membatasi jumlah marble dalam satu grup, jadi hapus pengecekan ini
    // Sekarang, grup bisa berisi lebih dari correctCount marble

    // Update semua marble yang terlibat
    final updates = <MarbleModel>[];
    final basePosition = targetMarble.position;
    int gridIndex = 0;

    for (int marbleId in marbleIdsInNewGroup) {
      final marble = marbles.firstWhere((m) => m.id == marbleId);
      final newPosition =
          basePosition +
          Offset(
            (gridIndex % 4) *
                25.0, // 4 marble per row, spacing 25px untuk tidak tumpang tindih
            (gridIndex ~/ 4) * 25.0, // spacing 25px between rows
          );

      updates.add(
        marble.copyWith(
          groupId: newGroupId,
          isGrouped: true,
          position: newPosition,
        ),
      );
      gridIndex++;
    }

    _updateMarbles(updates);
  }

  // Helper method untuk generate unique group ID
  int _generateNewGroupId() {
    final existingIds = marbles
        .where((m) => m.groupId != null)
        .map((m) => m.groupId!)
        .toSet();

    int newId = 1000; // Start from 1000 to avoid conflict with marble IDs
    while (existingIds.contains(newId)) {
      newId++;
    }
    return newId;
  }

  // Mengassign grup kelereng ke kartu target (allow any group, even wrong ones)
  void assignGroupToCard(int groupId, int cardId) {
    final targetCard = targetCards.firstWhere((card) => card.id == cardId);
    if (targetCard.hasGroup) return; // Kartu sudah memiliki grup

    final groupMarbles = marbles.where((m) => m.groupId == groupId).toList();

    // Allow assignment regardless of correct count - let user make mistakes
    if (groupMarbles.isEmpty) return; // Must have at least some marbles

    final correctCount = problem.dividend ~/ problem.divisor; // Should be 8
    final isCorrect = groupMarbles.length == correctCount;

    // Update status kartu
    targetCard.assignGroup(groupId);
    targetCard.isCorrect.value = isCorrect;

    // Update semua kelereng dalam grup
    final updates = <MarbleModel>[];
    for (var marble in groupMarbles) {
      updates.add(marble.copyWith(color: targetCard.color, isLocked: true));
    }

    _updateMarbles(updates);
  }

  // void checkAnswer() {
  //   hasCheckedAnswer.value = true; // Mark that check answer has been pressed

  //   bool allCorrect = true;
  //   int correctCards = 0;
  //   int wrongCards = 0;
  //   int emptyCards = 0;
  //   final correctCount = problem.dividend ~/ problem.divisor; // Should be 8

  //   for (var card in targetCards) {
  //     if (card.hasGroup) {
  //       final marbleCount = marbles
  //           .where((m) => m.groupId == card.assignedGroupId.value)
  //           .length;

  //       final isCorrect = marbleCount == correctCount;
  //       card.isCorrect.value = isCorrect;

  //       if (isCorrect) {
  //         correctCards++;
  //       } else {
  //         wrongCards++;
  //         allCorrect = false;
  //       }
  //     } else {
  //       // Empty card is considered wrong
  //       card.isCorrect.value = false;
  //       emptyCards++;
  //       allCorrect = false;
  //     }
  //   }

  //   // Enhanced dialog with detailed feedback
  //   Get.dialog(
  //     AlertDialog(
  //       title: Row(
  //         children: [
  //           Icon(
  //             allCorrect ? Icons.celebration : Icons.info_outline,
  //             color: allCorrect ? Colors.green : Colors.orange,
  //             size: 28,
  //           ),
  //           const SizedBox(width: 8),
  //           Text(
  //             allCorrect ? 'Perfect! 🎉' : 'Check Results',
  //             style: TextStyle(
  //               color: allCorrect ? Colors.green : Colors.black87,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ],
  //       ),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           if (allCorrect) ...[
  //             const Text(
  //               '🎉 Congratulations! All your answers are correct!',
  //               style: TextStyle(fontSize: 16),
  //             ),
  //             const SizedBox(height: 8),
  //             Text(
  //               'You correctly grouped ${problem.dividend} marbles into ${targetCards.length} groups of $correctCount each.',
  //               style: TextStyle(color: Colors.grey[600]),
  //             ),
  //           ] else ...[
  //             const Text(
  //               'Here are your results:',
  //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //             ),
  //             const SizedBox(height: 12),
  //             if (correctCards > 0) ...[
  //               Row(
  //                 children: [
  //                   const Icon(
  //                     Icons.check_circle,
  //                     color: Colors.green,
  //                     size: 20,
  //                   ),
  //                   const SizedBox(width: 8),
  //                   Text('$correctCards card(s) correct ✅'),
  //                 ],
  //               ),
  //               const SizedBox(height: 4),
  //             ],
  //             if (wrongCards > 0) ...[
  //               Row(
  //                 children: [
  //                   const Icon(Icons.cancel, color: Colors.red, size: 20),
  //                   const SizedBox(width: 8),
  //                   Text('$wrongCards card(s) wrong ❌'),
  //                 ],
  //               ),
  //               const SizedBox(height: 4),
  //             ],
  //             if (emptyCards > 0) ...[
  //               Row(
  //                 children: [
  //                   const Icon(Icons.warning, color: Colors.orange, size: 20),
  //                   const SizedBox(width: 8),
  //                   Text('$emptyCards card(s) empty ⚠️'),
  //                 ],
  //               ),
  //               const SizedBox(height: 8),
  //             ],
  //             Text(
  //               'Each card should have exactly $correctCount marbles.\nCheck the red-bordered cards and try again!',
  //               style: TextStyle(color: Colors.grey[600]),
  //             ),
  //           ],
  //         ],
  //       ),
  //       actions: [
  //         if (!allCorrect) ...[
  //           TextButton(
  //             onPressed: () {
  //               Get.back();
  //               resetGame();
  //             },
  //             child: const Text('Reset & Try Again'),
  //           ),
  //         ],
  //         TextButton(
  //           onPressed: () => Get.back(),
  //           child: Text(allCorrect ? 'Great!' : 'OK'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void checkAnswer() {
    // ✅ Don't set hasCheckedAnswer anymore since feedback is instant
    // hasCheckedAnswer.value = true; // Remove this line

    // Count results based on current card states
    int correctCards = 0;
    int wrongCards = 0;
    int emptyCards = 0;

    for (var card in targetCards) {
      if (card.hasGroup) {
        if (card.isCorrect.value) {
          correctCards++;
        } else {
          wrongCards++;
        }
      } else {
        emptyCards++;
      }
    }

    bool allCorrect = correctCards == targetCards.length && emptyCards == 0;

    // Show summary dialog
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(
              allCorrect ? Icons.celebration : Icons.info_outline,
              color: allCorrect ? Colors.green : Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              allCorrect ? 'Perfect! 🎉' : 'Game Summary',
              style: TextStyle(
                color: allCorrect ? Colors.green : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (allCorrect) ...[
              const Text(
                '🎉 Congratulations! All assignments are correct!',
                style: TextStyle(fontSize: 16),
              ),
            ] else ...[
              const Text(
                'Current status:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (correctCards > 0)
                Text('✅ $correctCards correct assignment(s)'),
              if (wrongCards > 0) Text('❌ $wrongCards wrong assignment(s)'),
              if (emptyCards > 0) Text('⚠️ $emptyCards empty card(s)'),
              const SizedBox(height: 8),
              const Text('Fix the red cards to complete the game!'),
            ],
          ],
        ),
        actions: [
          if (!allCorrect) ...[
            TextButton(
              onPressed: () {
                Get.back();
                resetGame();
              },
              child: const Text('Reset & Try Again'),
            ),
          ],
          TextButton(
            onPressed: () => Get.back(),
            child: Text(allCorrect ? 'Great!' : 'Continue'),
          ),
        ],
      ),
    );
  }

  void updateMarblePosition(int marbleId, Offset globalPosition) {
    final RenderBox box =
        playAreaKey.currentContext!.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(globalPosition);
    const double marbleSize = 40.0;

    final clampedPosition = Offset(
      localPosition.dx.clamp(0.0, box.size.width - marbleSize),
      localPosition.dy.clamp(0.0, box.size.height - marbleSize),
    );

    final marble = marbles.firstWhere((m) => m.id == marbleId);
    if (marble.isLocked) return;

    final updates = <MarbleModel>[];
    if (marble.groupId != null) {
      // Move entire group
      final groupMarbles = marbles
          .where((m) => m.groupId == marble.groupId)
          .toList();
      for (int i = 0; i < groupMarbles.length; i++) {
        final newPosition =
            clampedPosition +
            Offset(
              (i % 4) * 25.0, // 4 marble per row, spacing 25px
              (i ~/ 4) * 25.0, // spacing 25px between rows
            );
        updates.add(groupMarbles[i].copyWith(position: newPosition));
      }
    } else {
      updates.add(marble.copyWith(position: clampedPosition));
    }

    _updateMarbles(updates);
  }

  void ungroupMarble(int marbleId) {
    final marble = marbles.firstWhere((m) => m.id == marbleId);
    if (marble.isLocked || marble.groupId == null) return;

    final groupId = marble.groupId!;
    final groupMarbles = marbles.where((m) => m.groupId == groupId).toList();

    final updates = <MarbleModel>[];
    final Random random = Random();

    if (groupMarbles.length <= 2) {
      // Jika grup hanya 2 marble atau kurang, ungroup semua

      for (var groupMarble in groupMarbles) {
        updates.add(
          groupMarble.copyWith(
            groupId: null,
            isGrouped: false,
            isLocked: false,
            position:
                groupMarble.position +
                Offset(
                  (random.nextDouble() - 0.5) * 60,
                  (random.nextDouble() - 0.5) * 60,
                ),
          ),
        );
      }
    } else {
      // Jika grup lebih dari 2, hanya ungroup marble yang dipilih
      updates.add(
        marble.copyWith(
          groupId: null,
          isGrouped: false,
          isLocked: false,
          // Move marble sedikit dari grup
          position:
              marble.position +
              Offset(
                (random.nextDouble() - 0.5) * 80,
                (random.nextDouble() - 0.5) * 80,
              ),
        ),
      );

      // Reorganize remaining marbles in the group
      final remainingMarbles = groupMarbles
          .where((m) => m.id != marbleId)
          .toList();
      if (remainingMarbles.isNotEmpty) {
        final basePosition = remainingMarbles.first.position;
        for (int i = 0; i < remainingMarbles.length; i++) {
          updates.add(
            remainingMarbles[i].copyWith(
              position: basePosition + Offset((i % 4) * 15.0, (i ~/ 4) * 15.0),
            ),
          );
        }
      }
    }

    _updateMarbles(updates);
  }

  void updateMarblePositionDuringDrag(int marbleId, Offset globalPosition) {
    final RenderBox box =
        playAreaKey.currentContext!.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(globalPosition);
    const double marbleSize = 40.0;

    final clampedPosition = Offset(
      localPosition.dx.clamp(0.0, box.size.width - marbleSize),
      localPosition.dy.clamp(0.0, box.size.height - marbleSize),
    );

    final marble = marbles.firstWhere((m) => m.id == marbleId);
    if (marble.isLocked) return;

    final updates = <MarbleModel>[];
    if (marble.groupId != null) {
      // Move entire group during drag
      final groupMarbles = marbles
          .where((m) => m.groupId == marble.groupId)
          .toList();
      for (int i = 0; i < groupMarbles.length; i++) {
        final newPosition =
            clampedPosition +
            Offset(
              (i % 4) * 25.0, // spacing 25px untuk tidak tumpang tindih
              (i ~/ 4) * 25.0,
            );
        updates.add(groupMarbles[i].copyWith(position: newPosition));
      }
    } else {
      updates.add(marble.copyWith(position: clampedPosition));
    }

    _updateMarbles(updates);
  }

  @override
  void onInit() {
    super.onInit();
    initializeTargetCards();
    // Delay marble generation until after first frame to get accurate play area size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      generateMarbles();
    });
  }

  void initializeTargetCards() {
    targetCards.assignAll([
      TargetCardModel(id: 0, color: Colors.orangeAccent),
      TargetCardModel(id: 1, color: Colors.blue.shade400),
      TargetCardModel(id: 2, color: Colors.green),
    ]);
  }

  void generateMarbles() {
    // Get accurate play area size if available
    Size playAreaSize;

    try {
      final RenderBox? box =
          playAreaKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        playAreaSize = box.size;
      } else {
        // Fallback calculation accounting for target cards
        final double availableWidth =
            Get.width - 120 - 32; // Screen - target cards - padding
        final double availableHeight = Get.height * 0.6; // 60% of screen
        playAreaSize = Size(availableWidth, availableHeight);
      }
    } catch (e) {
      // Safe fallback if context not available yet
      final double availableWidth = Get.width - 120 - 32;
      final double availableHeight = Get.height * 0.6;
      playAreaSize = Size(availableWidth, availableHeight);
    }

    final Random random = Random();
    List<MarbleModel> newMarbles = [];

    for (int i = 0; i < problem.dividend; i++) {
      newMarbles.add(
        MarbleModel(
          id: i,
          position: Offset(
            20 +
                random.nextDouble() * (playAreaSize.width - 80), // Safe margins
            20 +
                random.nextDouble() *
                    (playAreaSize.height - 80), // Safe margins
          ),
        ),
      );
    }
    marbles.assignAll(newMarbles);
  }

  // Reset game functionality
  void resetGame() {
    // Reset check answer status
    hasCheckedAnswer.value = false;

    // Clear all groups and assignments
    final updates = <MarbleModel>[];
    for (var marble in marbles) {
      updates.add(
        marble.copyWith(
          groupId: null,
          isGrouped: false,
          isLocked: false,
          color: Colors.deepPurple,
        ),
      );
    }
    _updateMarbles(updates);

    // Reset target cards completely
    for (var card in targetCards) {
      card.clearGroup();
      card.isCorrect.value = false; // Reset correct status
    }

    // Regenerate marble positions
    generateMarbles();

    targetCards.refresh();

    Get.snackbar(
      'Game Reset',
      'Game has been reset. Try again!',
      backgroundColor: Colors.blue.withValues(alpha: .8),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}
