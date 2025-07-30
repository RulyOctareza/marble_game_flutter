import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

/// Widget for game action buttons (Reset and Check Answer)
class GameActionButtons extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onCheckAnswer;

  const GameActionButtons({
    super.key,
    required this.onReset,
    required this.onCheckAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Reset Game button
        Expanded(
          child: _buildActionButton(
            onTap: onReset,
            text: AppConstants.resetGroupsButton,
            backgroundColor: Colors.orange[300]!,
            borderColor: Colors.yellow[800]!,
            shadowColor: Colors.orange,
            textColor: Colors.orange[800]!,
          ),
        ),

        const SizedBox(width: 8),

        // Check Answer button
        Expanded(
          flex: 2,
          child: _buildActionButton(
            onTap: onCheckAnswer,
            text: AppConstants.checkAnswerButton,
            backgroundColor: Colors.green[300]!,
            borderColor: Colors.green[800]!,
            shadowColor: Colors.green,
            textColor: Colors.green[800]!,
          ),
        ),
      ],
    );
  }

  /// Build a styled action button
  Widget _buildActionButton({
    required VoidCallback onTap,
    required String text,
    required Color backgroundColor,
    required Color borderColor,
    required Color shadowColor,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: borderColor,
            width: 0.3,
          ),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusXLarge),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 1,
              spreadRadius: 2,
              offset: const Offset(1, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}