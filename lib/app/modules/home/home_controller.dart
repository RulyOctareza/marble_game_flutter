import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marble_game/app/data/models/marble_model.dart';
import 'package:marble_game/app/data/models/math_problem_model.dart';

class HomeController extends GetxController {
  final GlobalKey playAreaKey = GlobalKey();
  final String title = "Marble Grouping Game";

  final problem = MathProblemModel(dividend: 24, divisor: 3);

  final RxList<MarbleModel> marbles = <MarbleModel>[].obs;

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

  void groupMarbles(int draggedMarbleId, int targetMarbleId) {
    //
    // cari index dari kedua kelereng
    //
    final int draggedIndex = marbles.indexWhere((m) => m.id == draggedMarbleId);
    final int targetIndex = marbles.indexWhere((m) => m.id == targetMarbleId);

    //
    // jika kedua kelereng ditemukan
    //
    if (draggedIndex != -1 && targetIndex != -1) {
      //
      // ambil kelereng yang di drag dan kelereng target
      //
      final draggedMarble = marbles[draggedIndex];
      final targetMarble = marbles[targetIndex];

      final newGroupId = targetMarble.groupId ?? targetMarble.id;

      //
      // buat ulang objek kelereng yang di drag dan kelereng target
      //
      final updatedDraggedMarble = MarbleModel(
        id: draggedMarble.id,
        position: targetMarble.position + const Offset(20, 0),
        groupId: newGroupId,
      );

      //
      // buat ulang objek kelereng target
      //
      final updatedTargetMarble = MarbleModel(
        id: targetMarble.id,
        position: targetMarble.position,
        groupId: newGroupId,
      );

      //
      // update list kelereng
      //
      marbles[draggedIndex] = updatedDraggedMarble;
      marbles[targetIndex] = updatedTargetMarble;

      print(
        'Kelereng $draggedMarbleId & $targetMarbleId sekarang ada di grup $newGroupId',
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    generateMarbles();
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
