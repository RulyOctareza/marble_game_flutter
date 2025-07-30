import 'package:flutter/material.dart';
import '../../../data/models/marble_model.dart';
import '../../../core/constants/app_constants.dart';

/// Widget for displaying and handling interactions with a single marble
class MarbleWidget extends StatelessWidget {
  final MarbleModel marble;
  final bool isHighlighted;
  final bool canAccept;
  final Function(int, Offset) onDragUpdate;
  final Function(int, Offset) onDragEnd;
  final Function(int, int) onAccept;
  final VoidCallback onDoubleTap;

  const MarbleWidget({
    super.key,
    required this.marble,
    required this.isHighlighted,
    required this.canAccept,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onAccept,
    required this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: marble.position.dx,
      top: marble.position.dy,
      child: DragTarget<int>(
        builder: (context, candidateData, rejectedData) {
          return GestureDetector(
            onDoubleTap: onDoubleTap,
            child: AnimatedContainer(
              duration: AppConstants.marbleAnimationDuration,
              transform: isHighlighted
                  ? (Matrix4.identity()..scale(1.1))
                  : Matrix4.identity(),
              child: Draggable<int>(
                data: marble.id,
                feedback: _buildFeedbackMarble(),
                childWhenDragging: _buildDraggedMarble(),
                onDragUpdate: (details) {
                  if (!marble.isLocked) {
                    onDragUpdate(marble.id, details.globalPosition);
                  }
                },
                onDragEnd: (details) {
                  if (!marble.isLocked) {
                    onDragEnd(marble.id, details.offset);
                  }
                },
                child: _buildMarble(),
              ),
            ),
          );
        },
        onWillAcceptWithDetails: (data) =>
            !marble.isLocked && data.data != marble.id,
        onAcceptWithDetails: (details) {
          onAccept(details.data, marble.id);
        },
      ),
    );
  }

  /// Build the main marble widget
  Widget _buildMarble() {
    return Container(
      width: AppConstants.marbleSize,
      height: AppConstants.marbleSize,
      decoration: BoxDecoration(
        color: marble.color,
        shape: BoxShape.circle,
        border: Border.all(
          color: _getBorderColor(),
          width: _getBorderWidth(),
        ),
        boxShadow: _getMarbleShadow(),
      ),
    );
  }

  /// Build the feedback widget shown during drag
  Widget _buildFeedbackMarble() {
    return Container(
      width: AppConstants.feedbackMarbleSize,
      height: AppConstants.feedbackMarbleSize,
      decoration: BoxDecoration(
        color: marble.color.withValues(alpha: 0.8),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  /// Build the marble shown in original position during drag
  Widget _buildDraggedMarble() {
    return Container(
      width: AppConstants.marbleSize,
      height: AppConstants.marbleSize,
      decoration: BoxDecoration(
        color: marble.color.withValues(alpha: 0.3),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey,
          width: 2,
        ),
      ),
    );
  }

  /// Get appropriate border color based on marble state
  Color _getBorderColor() {
    if (marble.groupId != null) {
      return Colors.transparent;
    } else if (isHighlighted && canAccept) {
      return Colors.green;
    } else {
      return Colors.black;
    }
  }

  /// Get appropriate border width based on marble state
  double _getBorderWidth() {
    if (marble.groupId != null) {
      return 3.0;
    } else if (isHighlighted && canAccept) {
      return 2.5;
    } else {
      return 1.5;
    }
  }

  /// Get appropriate shadow for the marble
  List<BoxShadow> _getMarbleShadow() {
    List<BoxShadow> shadows = [];
    
    if (marble.groupId != null) {
      shadows.add(
        BoxShadow(
          color: Colors.black.withValues(alpha: 1),
          blurRadius: AppConstants.shadowBlurRadius,
          spreadRadius: 0,
        ),
      );
    }
    
    if (isHighlighted && canAccept) {
      shadows.add(
        BoxShadow(
          color: Colors.green.withValues(alpha: 0.3),
          blurRadius: AppConstants.highlightShadowBlur,
          spreadRadius: AppConstants.highlightShadowSpread,
        ),
      );
    }
    
    return shadows;
  }
}