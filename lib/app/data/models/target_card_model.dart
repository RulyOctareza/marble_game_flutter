import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

/// Model representing a target card where marble groups can be placed
/// Contains assignment state and correctness validation
class TargetCardModel {
  /// Unique identifier for this target card
  final int id;
  
  /// Visual color of the target card
  final Color color;
  
  /// ID of the marble group assigned to this card (reactive)
  final Rx<int?> assignedGroupId;
  
  /// Whether the assigned group has the correct number of marbles (reactive)
  final RxBool isCorrect;

  TargetCardModel({
    required this.id,
    required this.color,
    int? groupId,
    bool? isCorrect,
  }) : assignedGroupId = Rx<int?>(groupId),
       isCorrect = (isCorrect ?? false).obs;

  /// Check if this card has a group assigned to it
  bool get hasGroup => assignedGroupId.value != null;

  /// Assign a marble group to this target card
  void assignGroup(int groupId) {
    if (!hasGroup) {
      assignedGroupId.value = groupId;
    }
  }

  /// Clear the assigned group and reset correctness state
  void clearGroup() {
    assignedGroupId.value = null;
    isCorrect.value = false;
  }
}
