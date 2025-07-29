import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class TargetCardModel {
  final int id;
  final Color color;
  final Rx<int?> assignedGroupId; // ID grup yang ditugaskan ke kartu ini
  final RxBool isCorrect;
  

  TargetCardModel({
    required this.id,
    required this.color,
    int? groupId,
    bool? isCorrect,

  }) : assignedGroupId = Rx<int?>(groupId),
       isCorrect = (isCorrect ?? false).obs;

  bool get hasGroup => assignedGroupId.value != null;

  void assignGroup(int groupId) {
    if (!hasGroup) {
      assignedGroupId.value = groupId;
    }
  }

  void clearGroup() {
    assignedGroupId.value = null;
    isCorrect.value = false;
  }
}
