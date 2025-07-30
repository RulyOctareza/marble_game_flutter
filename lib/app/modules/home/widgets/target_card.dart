import 'package:flutter/material.dart';
import '../../../data/models/target_card_model.dart';
import '../../../core/constants/app_constants.dart';

/// Widget for displaying a single target card where marble groups can be dropped
class TargetCard extends StatelessWidget {
  final TargetCardModel card;
  final int marbleCount;
  final bool candidatePresent;
  final Function(int) onAccept;
  final Function(int) onWillAccept;

  const TargetCard({
    super.key,
    required this.card,
    required this.marbleCount,
    required this.candidatePresent,
    required this.onAccept,
    required this.onWillAccept,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: AppConstants.cardAnimationDuration,
          width: AppConstants.targetCardWidth,
          height: AppConstants.targetCardHeight,
          decoration: BoxDecoration(
            color: _getCardColor(),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            boxShadow: _getCardShadow(),
          ),
          child: Stack(
            children: [
              // Main card content
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (card.hasGroup) ...[
                      // Show marble count when group is assigned
                      Text(
                        '$marbleCount',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        AppConstants.marblesLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      // Show placeholder when empty
                      const SizedBox(height: 4),
                      const Icon(
                        Icons.add_circle_outline,
                        size: 30,
                        color: Colors.white54,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        AppConstants.dropGroupHere,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Status indicators
              if (card.hasGroup) _buildStatusIndicator(),
            ],
          ),
        );
      },
      onWillAcceptWithDetails: (details) {
        if (card.hasGroup) return false;
        return onWillAccept(details.data) > 0;
      },
      onAcceptWithDetails: (details) {
        onAccept(details.data);
      },
    );
  }

  /// Get the appropriate color for the card based on its state
  Color _getCardColor() {
    if (card.hasGroup) {
      return card.isCorrect.value
          ? card.color.withValues(alpha: 0.8)
          : card.color.withValues(alpha: 0.7);
    }
    return card.color.withValues(alpha: 0.8);
  }

  /// Get appropriate shadow for the card
  List<BoxShadow>? _getCardShadow() {
    if (card.hasGroup && !card.isCorrect.value) {
      return [
        BoxShadow(
          color: Colors.red.withValues(alpha: 0.5),
          blurRadius: 12,
          spreadRadius: 4,
        ),
      ];
    }
    return null;
  }

  /// Build status indicator (checkmark or X) for assigned groups
  Widget _buildStatusIndicator() {
    final bool isCorrect = card.isCorrect.value;
    
    return Positioned(
      top: 8,
      left: 20,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          isCorrect ? Icons.check : Icons.close,
          color: isCorrect ? Colors.green : Colors.red,
          size: 16,
          weight: 800,
        ),
      ),
    );
  }
}