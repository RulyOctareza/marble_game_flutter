import 'package:flutter/material.dart';
import 'package:marble_game/app/data/models/marble_model.dart';

/// Custom painter for drawing connection lines between grouped marbles
/// Visualizes which marbles belong to the same group
class GroupConnectionPainter extends CustomPainter {
  /// List of all marbles to check for grouping
  final List<MarbleModel> marbles;
  
  /// Radius of each marble for positioning calculations
  final double marbleRadius;

  GroupConnectionPainter({
    required this.marbles, 
    this.marbleRadius = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Group marbles by their group ID
    final groups = <int, List<MarbleModel>>{};
    for (var marble in marbles) {
      if (marble.groupId != null) {
        (groups[marble.groupId!] ??= []).add(marble);
      }
    }

    // Draw lines connecting marbles in each group
    groups.forEach((groupId, groupMarbles) {
      if (groupMarbles.length > 1 && !groupMarbles.first.isLocked) {
        // Draw lines between every pair of marbles in the group
        for (int i = 0; i < groupMarbles.length; i++) {
          for (int j = i + 1; j < groupMarbles.length; j++) {
            // Calculate center points of each marble
            final startPoint = groupMarbles[i].position + 
                Offset(marbleRadius, marbleRadius);
            final endPoint = groupMarbles[j].position + 
                Offset(marbleRadius, marbleRadius);

            // Draw connecting line
            canvas.drawLine(startPoint, endPoint, paint);
          }
        }
      }
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Always repaint to ensure lines are updated when marbles move
    return true;
  }
}
