import 'package:flutter/material.dart';
import 'package:marble_game/app/data/models/marble_model.dart';

class GroupConnectionPainter extends CustomPainter {
  final List<MarbleModel> marbles;
  final double marbleRadius;

  GroupConnectionPainter({required this.marbles, this.marbleRadius = 20.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Kelompokkan kelereng berdasarkan groupId
    final groups = <int, List<MarbleModel>>{};
    for (var marble in marbles) {
      if (marble.groupId != null) {
        (groups[marble.groupId!] ??= []).add(marble);
      }
    }

    // Gambar garis untuk setiap grup
    groups.forEach((groupId, groupMarbles) {
      if (groupMarbles.length > 1 && !groupMarbles.first.isLocked) {
        // Iterasi untuk setiap pasangan kelereng dalam grup
        for (int i = 0; i < groupMarbles.length; i++) {
          for (int j = i + 1; j < groupMarbles.length; j++) {
            // Hitung titik tengah dari setiap kelereng
            final startPoint =
                groupMarbles[i].position + Offset(marbleRadius, marbleRadius);
            final endPoint =
                groupMarbles[j].position + Offset(marbleRadius, marbleRadius);

            // Gambar garis yang menghubungkan kedua titik
            canvas.drawLine(startPoint, endPoint, paint);
          }
        }
      }
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Selalu repaint jika ada perubahan untuk memastikan garis selalu update
    return true;
  }
}
