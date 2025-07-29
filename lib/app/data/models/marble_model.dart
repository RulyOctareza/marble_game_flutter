import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MarbleModel {
  final int id;
  final Offset position;
  final int? groupId;
  final Color color;
  final bool isGrouped;
  final bool isLocked; // true jika sudah di-assign ke kartu target

  MarbleModel({
    required this.id,
    required this.position,
    this.groupId,
    this.color = Colors.blue,
    this.isGrouped = false,
    this.isLocked = false,
  });

  // Method untuk membuat salinan MarbleModel dengan properti yang diperbarui
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
