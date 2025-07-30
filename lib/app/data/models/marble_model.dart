import 'package:flutter/material.dart';

/// Model representing a marble in the game
/// Contains position, grouping information, and visual state
class MarbleModel {
  /// Unique identifier for this marble
  final int id;
  
  /// Current position of the marble on screen
  final Offset position;
  
  /// ID of the group this marble belongs to (null if ungrouped)
  final int? groupId;
  
  /// Visual color of the marble
  final Color color;
  
  /// Whether this marble is part of a group
  final bool isGrouped;
  
  /// Whether this marble is locked (assigned to a target card)
  final bool isLocked;

  MarbleModel({
    required this.id,
    required this.position,
    this.groupId,
    this.color = Colors.blue,
    this.isGrouped = false,
    this.isLocked = false,
  });

  /// Create a copy of this marble with updated properties
  /// Used for immutable state updates
  MarbleModel copyWith({
    int? id,
    Offset? position,
    int? groupId,
    Color? color,
    bool? isGrouped,
    bool? isLocked,
  }) {
    return MarbleModel(
      id: id ?? this.id,
      position: position ?? this.position,
      groupId: groupId ?? this.groupId,
      color: color ?? this.color,
      isGrouped: isGrouped ?? this.isGrouped,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}
