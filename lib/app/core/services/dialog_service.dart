import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_constants.dart';

/// Service class to handle game dialogs and user feedback
class DialogService {
  // Private constructor to prevent instantiation
  DialogService._();

  /// Show level completion dialog
  static void showLevelCompleteDialog({
    required int currentLevel,
    required int totalLevels,
    required String problemText,
    required VoidCallback onNextLevel,
  }) {
    final bool isLastLevel = currentLevel >= totalLevels;
    
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.celebration,
              color: Colors.green,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              AppConstants.perfectTitle,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎉 Excellent! You solved $problemText',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Level $currentLevel completed!',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: onNextLevel,
            child: Text(
              isLastLevel 
                ? AppConstants.finishGameButton 
                : AppConstants.nextLevelButton,
            ),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(AppConstants.stayHereButton),
          ),
        ],
      ),
    );
  }

  /// Show game summary dialog for incomplete answers
  static void showGameSummaryDialog({
    required int correctCards,
    required int wrongCards,
    required int emptyCards,
    required int expectedMarbles,
    required VoidCallback onTryAgain,
  }) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text(
              AppConstants.gameSummaryTitle,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current status:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (correctCards > 0)
              Text('✅ $correctCards correct assignment(s)'),
            if (wrongCards > 0) 
              Text('❌ $wrongCards wrong assignment(s)'),
            if (emptyCards > 0) 
              Text('⚠️ $emptyCards empty card(s)'),
            const SizedBox(height: 8),
            Text(
              'Each card needs exactly $expectedMarbles marbles!',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              onTryAgain();
            },
            child: const Text(AppConstants.tryAgainButton),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(AppConstants.continueButton),
          ),
        ],
      ),
    );
  }

  /// Show game completion dialog
  static void showGameCompletionDialog({
    required VoidCallback onPlayAgain,
  }) {
    Get.dialog(
      AlertDialog(
        title: const Text(AppConstants.congratulationsTitle),
        content: const Text(AppConstants.gameCompletedMessage),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              onPlayAgain();
            },
            child: const Text(AppConstants.playAgainButton),
          ),
        ],
      ),
    );
  }

  /// Show level progress snackbar
  static void showLevelProgressSnackbar({
    required int level,
    required String problemText,
  }) {
    Get.snackbar(
      'Level $level',
      'New challenge! Solve: $problemText',
      backgroundColor: Colors.blue.withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: AppConstants.snackbarDuration,
    );
  }
}