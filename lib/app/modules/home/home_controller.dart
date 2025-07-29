import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marble_game/app/data/models/marble_model.dart';
import 'package:marble_game/app/data/models/math_problem_model.dart';
import 'package:marble_game/app/data/models/target_card_model.dart';

class HomeController extends GetxController {
  final GlobalKey playAreaKey = GlobalKey();
  final String title = "Marble Grouping Game";

  final Rx<MathProblemModel> problem = MathProblemModel(
    dividend: 24,
    divisor: 3,
  ).obs;
  // Menggunakan .obs untuk setiap marble individual
  final marbles = <MarbleModel>[].obs;
  final targetCards = <TargetCardModel>[].obs;

  // Track if check answer has been pressed
  final hasCheckedAnswer = false.obs;

  // ✅ Add current level tracking
  final currentLevel = 1.obs;
  final totalLevels = 10.obs;

  final List<Color> groupColors = [
    Colors.deepPurpleAccent,
    Colors.purple,
    Colors.red,
    Colors.redAccent,
    Colors.green,
    Colors.teal,
    Colors.brown,
  ];

  @override
  void onInit() {
    super.onInit();
    initializeTargetCards();
    // Delay marble generation until after first frame to get accurate play area size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      generateMarbles();
    });
  }

  // ✅ New method to start a completely new game
  void startNewGame() {
    // Generate new random problem
    problem.value = MathProblemModel.getRandomProblem();

    // Reset state
    hasCheckedAnswer.value = false;

    // Clear all groups and assignments
    final updates = <MarbleModel>[];
    for (var marble in marbles) {
      updates.add(
        marble.copyWith(
          groupId: null,
          isGrouped: false,
          isLocked: false,
          color: Colors.blue,
        ),
      );
    }
    _updateMarbles(updates);

    // Reset target cards completely
    for (var card in targetCards) {
      card.clearGroup();
      card.isCorrect.value = false;
    }

    // Generate marbles based on new problem
    WidgetsBinding.instance.addPostFrameCallback((_) {
      generateMarbles();
    });
  }

  // ✅ Method to go to next level
  void nextLevel() {
    if (currentLevel.value < totalLevels.value) {
      currentLevel.value++;
      startNewGame(); // Generate new problem

      Get.snackbar(
        'Level ${currentLevel.value}',
        'New challenge! Solve: ${problem.value.dividend} ÷ ${problem.value.divisor}',
        backgroundColor: Colors.blue.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } else {
      // Game completed
      Get.dialog(
        AlertDialog(
          title: const Text('🎉 Congratulations!'),
          content: const Text('You have completed all levels!'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                currentLevel.value = 1;
                startNewGame();
              },
              child: const Text('Play Again'),
            ),
          ],
        ),
      );
    }
  }

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

  // lib/app/modules/home/home_controller.dart

  // Mengelompokkan kelereng saat di-drag satu sama lain
  void groupMarbles(int draggedMarbleId, int targetMarbleId) {
    if (draggedMarbleId == targetMarbleId) return;

    final draggedMarble = marbles.firstWhere((m) => m.id == draggedMarbleId);
    final targetMarble = marbles.firstWhere((m) => m.id == targetMarbleId);

    if (targetMarble.isLocked || draggedMarble.isLocked) return;

    // Tentukan group ID yang akan digunakan
    int newGroupId =
        targetMarble.groupId ?? draggedMarble.groupId ?? _generateNewGroupId();

    // Gabungkan semua ID unik dari grup yang terlibat
    final Set<int> marbleIdsInNewGroup = {};
    for (var marble in [draggedMarble, targetMarble]) {
      if (marble.groupId != null) {
        marbleIdsInNewGroup.addAll(
          marbles.where((m) => m.groupId == marble.groupId).map((m) => m.id),
        );
      } else {
        marbleIdsInNewGroup.add(marble.id);
      }
    }

    // ✅ Tentukan warna baru berdasarkan jumlah total anggota grup
    final groupSize = marbleIdsInNewGroup.length;
    Color newColor = Colors.blue; // Warna default
    if (groupSize >= 2) {
      // Ambil warna dari palet, jika lebih besar dari palet, gunakan warna terakhir
      newColor = groupColors[min(groupSize - 2, groupColors.length - 1)];
    }

    // ✅ Logika baru untuk posisi kelopak bunga (flower petal)
    final updates = <MarbleModel>[];
    final basePosition = targetMarble.position;
    final double radius = 14.0 + (groupSize * 2.5);
    int i = 0;

    for (int marbleId in marbleIdsInNewGroup) {
      final marble = marbles.firstWhere((m) => m.id == marbleId);
      Offset newPosition;

      if (groupSize <= 1) {
        newPosition = basePosition;
      } else {
        // Hitung sudut untuk setiap kelereng agar membentuk lingkaran
        final angle = (2 * pi / groupSize) * i;
        newPosition =
            basePosition + Offset(radius * cos(angle), radius * sin(angle));
      }

      updates.add(
        marble.copyWith(
          groupId: newGroupId,
          isGrouped: true,
          position: newPosition,
          color: newColor, // Terapkan warna baru
        ),
      );
      i++;
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

    final correctCount =
        problem.value.dividend ~/ problem.value.divisor; // Should be 8
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
              Text(
                '🎉 Excellent! You solved ${problem.value.dividend} ÷ ${problem.value.divisor} = ${problem.value.dividend ~/ problem.value.divisor}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Level ${currentLevel.value} completed!',
                style: const TextStyle(fontWeight: FontWeight.bold),
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
              Text(
                'Each card needs exactly ${problem.value.dividend ~/ problem.value.divisor} marbles!',
              ),
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
              child: const Text('Try Again'),
            ),
          ],
          if (allCorrect) ...[
            TextButton(
              onPressed: () {
                Get.back();
                nextLevel(); // ✅ Go to next level
              },
              child: Text(
                currentLevel.value < totalLevels.value
                    ? 'Next Level'
                    : 'Finish Game',
              ),
            ),
          ],
          TextButton(
            onPressed: () => Get.back(),
            child: Text(allCorrect ? 'Stay Here' : 'Continue'),
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
      final groupMarbles = marbles
          .where((m) => m.groupId == marble.groupId)
          .toList();
      final groupSize = groupMarbles.length;
      final double radius = 14.0 + (groupSize * 2.5);

      for (int i = 0; i < groupSize; i++) {
        final angle = (2 * pi / groupSize) * i;
        final newPosition =
            clampedPosition + Offset(radius * cos(angle), radius * sin(angle));
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
      final groupMarbles = marbles
          .where((m) => m.groupId == marble.groupId)
          .toList();
      final groupSize = groupMarbles.length;
      final double radius = 14.0 + (groupSize * 2.5);

      for (int i = 0; i < groupSize; i++) {
        final angle = (2 * pi / groupSize) * i;
        final newPosition =
            clampedPosition + Offset(radius * cos(angle), radius * sin(angle));
        updates.add(groupMarbles[i].copyWith(position: newPosition));
      }
    } else {
      updates.add(marble.copyWith(position: clampedPosition));
    }

    _updateMarbles(updates);
  }

  // ✅ Method to manually change problem (for testing)
  void changeProblem() {
    startNewGame();
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

    // ✅ Generate marbles based on current problem dividend
    final totalMarbles = problem.value.dividend;

    for (int i = 0; i < totalMarbles; i++) {
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

    // Reset level to 1
    currentLevel.value = 1;

    // Clear all groups and assignments
    final updates = <MarbleModel>[];
    for (var marble in marbles) {
      updates.add(
        marble.copyWith(
          groupId: null,
          isGrouped: false,
          isLocked: false,
          color: Colors.blue,
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

    // Get.snackbar(
    //   'Game Reset',
    //   'Try again! Solve: ${problem.value.dividend} ÷ ${problem.value.divisor}',
    //   backgroundColor: Colors.blue.withValues(alpha: .8),
    //   colorText: Colors.white,
    //   duration: const Duration(seconds: 2),
    // );
  }
}
