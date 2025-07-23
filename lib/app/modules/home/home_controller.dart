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
    if (targetMarble.isLocked) return;

    // Tentukan groupId yang akan digunakan
    final newGroupId = targetMarble.groupId ?? targetMarbleId;

    // Hitung total kelereng yang akan ada dalam grup
    final existingGroupCount = marbles
        .where((m) => m.groupId == newGroupId)
        .length;
    final willBeGroupedCount = draggedMarble.groupId == null
        ? 1
        : marbles.where((m) => m.groupId == draggedMarble.groupId).length;

    // Jika total melebihi jawaban yang benar, batalkan
    if (existingGroupCount + willBeGroupedCount >
        (problem.dividend ~/ problem.divisor)) {
      return;
    }

    var updates = <MarbleModel>[];
    var gridIndex = 0;
    final basePosition = targetMarble.position;

    // Update marble yang di-drag dan marble dalam grupnya (jika ada)
    if (draggedMarble.groupId != null) {
      final draggingGroup = marbles.where(
        (m) => m.groupId == draggedMarble.groupId,
      );
      for (var marble in draggingGroup) {
        updates.add(
          marble.copyWith(
            groupId: newGroupId,
            isGrouped: true,
            position:
                basePosition +
                Offset(
                  (gridIndex % 3) * 20.0, // Jarak horizontal antar marble
                  (gridIndex ~/ 3) * 20.0, // Jarak vertikal antar marble
                ),
          ),
        );
        gridIndex++;
      }
    } else {
      updates.add(
        draggedMarble.copyWith(
          groupId: newGroupId,
          isGrouped: true,
          position: basePosition + const Offset(20, 0),
        ),
      );
      gridIndex++;
    }

    // Update marble target dan marble dalam grupnya (jika ada)
    if (targetMarble.groupId != null) {
      final targetGroup = marbles.where(
        (m) => m.groupId == targetMarble.groupId,
      );
      for (var marble in targetGroup) {
        if (marble.id != targetMarble.id) {
          updates.add(
            marble.copyWith(
              groupId: newGroupId,
              isGrouped: true,
              position:
                  basePosition +
                  Offset((gridIndex % 3) * 20.0, (gridIndex ~/ 3) * 20.0),
            ),
          );
          gridIndex++;
        }
      }
    }

    // Update target marble
    updates.add(
      targetMarble.copyWith(
        groupId: newGroupId,
        isGrouped: true,
        position: basePosition,
      ),
    );

    _updateMarbles(updates);
  }

  // Mengassign grup kelereng ke kartu target
  void assignGroupToCard(int groupId, int cardId) {
    final targetCard = targetCards.firstWhere((card) => card.id == cardId);
    if (targetCard.hasGroup) return; // Kartu sudah memiliki grup

    final groupMarbles = marbles.where((m) => m.groupId == groupId);
    if (groupMarbles.length != (problem.dividend ~/ problem.divisor))
      return; // Jumlah tidak sesuai

    // Update status kartu
    targetCard.assignGroup(groupId);

    // Update semua kelereng dalam grup
    for (var marble in groupMarbles) {
      final index = marbles.indexWhere((m) => m.id == marble.id);
      marbles[index] = marble.copyWith(color: targetCard.color, isLocked: true);
    }
  }

  void checkAnswer() {
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

    var updates = <MarbleModel>[];
    if (marble.groupId != null) {
      var index = 0;
      for (var groupMarble in marbles.where(
        (m) => m.groupId == marble.groupId,
      )) {
        updates.add(
          groupMarble.copyWith(
            position:
                clampedPosition +
                Offset((index % 3) * 20.0, (index ~/ 3) * 20.0),
          ),
        );
        index++;
      }
    } else {
      updates.add(marble.copyWith(position: clampedPosition));
    }

    _updateMarbles(updates);
  }

  void ungroupMarble(int marbleId) {
    final marble = marbles.firstWhere((m) => m.id == marbleId);
    if (marble.isLocked || marble.groupId == null) return;

    final updates = <MarbleModel>[];
    updates.add(marble.copyWith(groupId: null, isGrouped: false));

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

    // Perbarui posisi secara real-time
    if (marble.groupId != null) {
      var index = 0;
      final updates = <MarbleModel>[];
      for (var groupMarble in marbles.where(
        (m) => m.groupId == marble.groupId,
      )) {
        updates.add(
          groupMarble.copyWith(
            position:
                clampedPosition +
                Offset((index % 3) * 20.0, (index ~/ 3) * 20.0),
          ),
        );
        index++;
      }
      _updateMarbles(updates);
    } else {
      _updateMarbles([marble.copyWith(position: clampedPosition)]);
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
            random.nextDouble() * (playAreaSize.width - 40),
            random.nextDouble() * (playAreaSize.height - 40),
          ),
        ),
      );
    }
    marbles.assignAll(newMarbles);
  }
}
