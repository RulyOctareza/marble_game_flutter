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

    final correctCount = problem.dividend ~/ problem.divisor; // 24 ÷ 3 = 8

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
    if (marbleIdsInNewGroup.length > correctCount) {
      return;
    }

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

    // Update status kartu
    targetCard.assignGroup(groupId);

    // Update semua kelereng dalam grup
    final updates = <MarbleModel>[];
    for (var marble in groupMarbles) {
      updates.add(marble.copyWith(color: targetCard.color, isLocked: true));
    }

    _updateMarbles(updates);
  }

  void checkAnswer() {
    hasCheckedAnswer.value = true; // Mark that check answer has been pressed

    bool allCorrect = true;
    final correctCount = problem.dividend ~/ problem.divisor;

    for (var card in targetCards) {
      final hasCorrectGroup =
          card.hasGroup &&
          marbles
                  .where((m) => m.groupId == card.assignedGroupId.value)
                  .length ==
              correctCount;

      card.isCorrect.value = hasCorrectGroup;
      if (!hasCorrectGroup) allCorrect = false;
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
            // Spread marbles sedikit dari posisi asli
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
      TargetCardModel(id: 0, color: Colors.red),
      TargetCardModel(id: 1, color: Colors.yellow),
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
          color: Colors.deepPurple, // Reset to original color
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

    Get.snackbar(
      'Game Reset',
      'Game has been reset. Try again!',
      backgroundColor: Colors.blue.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}
