import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:marble_game/app/data/models/marble_model.dart';

class TargetCardModel {
  final int id;
  final Color color;
  final RxList<MarbleModel> marbles;
  final RxBool isCorrect;

  TargetCardModel({
    required this.id,
    required this.color,
    List<MarbleModel>? marbles,
    bool? isCorrect,
  }) : marbles = (marbles ?? []).obs,
       isCorrect = (isCorrect ?? false).obs;
}
