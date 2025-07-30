import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/group_connection_painter.dart';
import '../home/home_controller.dart';
import '../home/widgets/game_header.dart';
import '../home/widgets/problem_display.dart';
import '../home/widgets/target_card.dart';
import '../home/widgets/marble_widget.dart';
import '../home/widgets/game_action_buttons.dart';

/// Main view for the Marble Game home screen
/// Displays the game interface and handles user interactions
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[200],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Game header with title and level info
              Obx(
                () => GameHeader(
                  currentLevel: controller.currentLevel.value,
                  totalLevels: controller.totalLevels.value,
                  onNewProblem: controller.changeProblem,
                ),
              ),

              const SizedBox(height: 8),

              // Math problem display
              Obx(
                () => ProblemDisplay(
                  dividend: controller.problem.value.dividend,
                  divisor: controller.problem.value.divisor,
                ),
              ),

              const SizedBox(height: 12),

              // Main game area with target cards and marbles
              Expanded(
                child: Row(
                  children: [
                    // Target cards column
                    _buildTargetCardsColumn(),

                    // Play area with marbles
                    _buildPlayArea(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              GameActionButtons(
                onReset: controller.resetGame,
                onCheckAnswer: controller.checkAnswer,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the column of target cards
  Widget _buildTargetCardsColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(
        controller.targetCards.length,
        (index) => Obx(() {
          final card = controller.targetCards[index];
          final marbleCount = controller.marbles
              .where((m) => m.groupId == card.assignedGroupId.value)
              .length;

          return TargetCard(
            card: card,
            marbleCount: marbleCount,
            candidatePresent:
                false, // This could be enhanced to show drag feedback
            onAccept: (marbleId) {
              final marble = controller.marbles.firstWhere(
                (m) => m.id == marbleId,
              );
              if (marble.groupId != null) {
                controller.assignGroupToCard(marble.groupId!, card.id);
              }
            },
            onWillAccept: (marbleId) {
              final marble = controller.marbles.firstWhere(
                (m) => m.id == marbleId,
              );
              return marble.groupId != null ? 1 : 0;
            },
          );
        }),
      ),
    );
  }

  /// Build the main play area containing marbles
  Widget _buildPlayArea() {
    return Expanded(
      child: Container(
        key: controller.playAreaKey,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Obx(() {
          return Stack(
            children: [
              // Render all marbles
              ..._buildMarbles(),

              // Connection lines between grouped marbles
              _buildConnectionLines(),
            ],
          );
        }),
      ),
    );
  }

  /// Build all marble widgets
  List<Widget> _buildMarbles() {
    return controller.marbles.map((marble) {
      return MarbleWidget(
        marble: marble,
        isHighlighted: false, // Could be enhanced to show drag feedback
        canAccept: !marble.isLocked,
        onDragUpdate: controller.updateMarblePositionDuringDrag,
        onDragEnd: controller.updateMarblePosition,
        onAccept: controller.groupMarbles,
        onDoubleTap: () => controller.ungroupMarble(marble.id),
      );
    }).toList();
  }

  /// Build connection lines painter
  Widget _buildConnectionLines() {
    return IgnorePointer(
      ignoring: true,
      child: CustomPaint(
        painter: GroupConnectionPainter(marbles: controller.marbles.toList()),
        size: Size.infinite,
      ),
    );
  }
}
