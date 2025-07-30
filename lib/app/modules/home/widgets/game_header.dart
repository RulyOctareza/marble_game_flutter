import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

/// Widget for displaying the game header with title and level information
class GameHeader extends StatelessWidget {
  final int currentLevel;
  final int totalLevels;
  final VoidCallback onNewProblem;

  const GameHeader({
    super.key,
    required this.currentLevel,
    required this.totalLevels,
    required this.onNewProblem,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Game instruction container
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.purple,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusXLarge),
          ),
          child: const Text(
            AppConstants.gameInstruction,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 8),

        // Level indicator and New Problem button row
        Row(
          children: [
            // Level indicator
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                ),
                child: Column(
                  children: [
                    Text(
                      'Level $currentLevel/$totalLevels',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // New Problem button
            Expanded(
              child: ElevatedButton(
                onPressed: onNewProblem,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                  ),
                ),
                child: const Text(
                  AppConstants.newProblemButton,
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}