import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Game-specific utility functions and helpers
class GameUtils {
  // Private constructor to prevent instantiation
  GameUtils._();

  /// Calculate the snap point position for target cards
  static Offset getSnapPointForCard(int cardId) {
    switch (cardId) {
      case 0:
        return const Offset(-1, 60); // Top card position
      case 1:
        return const Offset(-1, 220); // Middle card position
      case 2:
        return const Offset(-1, 360); // Bottom card position
      default:
        return const Offset(-1, 50); // Default position
    }
  }

  /// Calculate circular position for grouped marbles
  static Offset calculateCircularPosition({
    required Offset basePosition,
    required double radius,
    required int index,
    required int totalMarbles,
  }) {
    if (totalMarbles <= 1) {
      return basePosition;
    }

    final angle = (2 * math.pi / totalMarbles) * index;
    return basePosition +
        Offset(radius * math.cos(angle), radius * math.sin(angle));
  }

  /// Calculate grid position for marbles in target cards
  static Offset calculateGridPosition({
    required Offset basePosition,
    required int index,
    required double spacing,
    int itemsPerRow = 4,
  }) {
    return basePosition +
        Offset(
          (index % itemsPerRow) * spacing,
          (index ~/ itemsPerRow) * spacing,
        );
  }

  /// Generate random offset within bounds
  static Offset generateRandomOffset({
    required double maxWidth,
    required double maxHeight,
    required double margin,
    required double random1,
    required double random2,
  }) {
    return Offset(
      margin + random1 * (maxWidth - 2 * margin),
      margin + random2 * (maxHeight - 2 * margin),
    );
  }

  /// Clamp position within play area bounds
  static Offset clampPosition({
    required Offset position,
    required Size playAreaSize,
    required double marbleSize,
  }) {
    return Offset(
      position.dx.clamp(0.0, playAreaSize.width - marbleSize),
      position.dy.clamp(0.0, playAreaSize.height - marbleSize),
    );
  }

  /// Calculate group radius based on group size
  static double calculateGroupRadius(
    int groupSize, {
    double baseRadius = 14.0,
    double multiplier = 2.5,
  }) {
    return baseRadius + (groupSize * multiplier);
  }
}
