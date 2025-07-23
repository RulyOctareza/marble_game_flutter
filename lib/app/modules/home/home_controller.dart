import 'dart:math';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:marble_game/app/data/models/marble_model.dart';
import 'package:marble_game/app/data/models/math_problem_model.dart';

class HomeController extends GetxController {
  final String title = "Marble Grouping Game";

  final problem = MathProblemModel(dividend: 24, divisor: 3);

  final RxList<MarbleModel> marbles = <MarbleModel>[].obs;

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
