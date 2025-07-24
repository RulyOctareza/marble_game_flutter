import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0D9FF),
      appBar: AppBar(
        title: Text(controller.title),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Problem Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(
                  0xFF8B4CB8,
                ), // Purple background like assignment
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Header text like in assignment
                  const Text(
                    'Find the result of the division',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Problem equation in dark purple container
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF5A2D6F,
                      ), // Darker purple like assignment
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${controller.problem.dividend} ÷ ${controller.problem.divisor}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Equals sign in black background
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '=',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: Row(
                children: [
                  // Target Cards Column
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(
                      controller.targetCards.length,
                      (index) => Obx(() {
                        final card = controller.targetCards[index];
                        return DragTarget<int>(
                          builder: (context, candidateData, rejectedData) {
                            return Container(
                              width: 80,
                              height: 120,
                              decoration: BoxDecoration(
                                color: card.hasGroup
                                    ? card.color.withOpacity(0.8)
                                    : card.color.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      candidateData.isNotEmpty && !card.hasGroup
                                      ? Colors.white
                                      : controller.hasCheckedAnswer.value &&
                                            card.hasGroup
                                      ? (card.isCorrect.value
                                            ? Colors.green
                                            : Colors.red)
                                      : card.hasGroup
                                      ? card.color
                                      : Colors.grey,
                                  width:
                                      controller.hasCheckedAnswer.value &&
                                          card.hasGroup
                                      ? 4
                                      : candidateData.isNotEmpty
                                      ? 3
                                      : 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (card.hasGroup) ...[
                                    Text(
                                      '${controller.marbles.where((m) => m.groupId == card.assignedGroupId.value).length}',
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Text(
                                      'marbles',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    // Show correct/wrong icon only after check answer
                                    if (controller.hasCheckedAnswer.value) ...[
                                      const SizedBox(height: 4),
                                      Icon(
                                        card.isCorrect.value
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: card.isCorrect.value
                                            ? Colors.green
                                            : Colors.red,
                                        size: 20,
                                      ),
                                    ],
                                  ] else ...[
                                    const Icon(
                                      Icons.add_circle_outline,
                                      size: 30,
                                      color: Colors.white54,
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Drop\ngroup here',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                          onWillAcceptWithDetails: (details) {
                            if (card.hasGroup)
                              return false; // Card sudah terisi

                            // Check if the dragged marble is part of a group
                            final marbleId = details.data;
                            final marble = controller.marbles.firstWhere(
                              (m) => m.id == marbleId,
                            );

                            // Allow any group assignment, even if wrong count
                            return marble.groupId !=
                                null; // Must be part of a group
                          },
                          onAcceptWithDetails: (details) {
                            final marbleId = details.data;
                            final marble = controller.marbles.firstWhere(
                              (m) => m.id == marbleId,
                            );
                            controller.assignGroupToCard(
                              marble.groupId!,
                              card.id,
                            );
                          },
                        );
                      }),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Play Area
                  Expanded(
                    child: Container(
                      key: controller.playAreaKey,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Obx(() {
                        return Stack(
                          children: controller.marbles.map((marble) {
                            return Positioned(
                              left: marble.position.dx,
                              top: marble.position.dy,
                              child: DragTarget<int>(
                                builder: (context, candidateData, rejectedData) {
                                  // Enhanced visual feedback for drag operations
                                  final isHighlighted =
                                      candidateData.isNotEmpty;
                                  final canAccept =
                                      !marble.isLocked &&
                                      candidateData.isNotEmpty &&
                                      candidateData.first != marble.id;

                                  return GestureDetector(
                                    onDoubleTap: () {
                                      controller.ungroupMarble(marble.id);
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      transform: isHighlighted
                                          ? (Matrix4.identity()..scale(1.1))
                                          : Matrix4.identity(),
                                      child: Draggable<int>(
                                        data: marble.id,
                                        feedback: Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: marble.color.withOpacity(
                                              0.8,
                                            ),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 3,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.4,
                                                ),
                                                blurRadius: 15,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                        childWhenDragging: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: marble.color.withOpacity(
                                              0.3,
                                            ),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.grey,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        onDragUpdate: (details) {
                                          if (!marble.isLocked) {
                                            controller
                                                .updateMarblePositionDuringDrag(
                                                  marble.id,
                                                  details.globalPosition,
                                                );
                                          }
                                        },
                                        onDragEnd: (details) {
                                          if (!marble.isLocked) {
                                            controller.updateMarblePosition(
                                              marble.id,
                                              details.offset,
                                            );
                                          }
                                        },
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: marble.color,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: marble.groupId != null
                                                  ? Colors.yellow
                                                  : isHighlighted && canAccept
                                                  ? Colors.green
                                                  : Colors.black,
                                              width: marble.groupId != null
                                                  ? 3.0
                                                  : isHighlighted && canAccept
                                                  ? 2.5
                                                  : 1.5,
                                            ),
                                            boxShadow: [
                                              if (marble.groupId != null)
                                                BoxShadow(
                                                  color: Colors.yellow
                                                      .withOpacity(0.5),
                                                  blurRadius: 6,
                                                  spreadRadius: 1,
                                                ),
                                              if (isHighlighted && canAccept)
                                                BoxShadow(
                                                  color: Colors.green
                                                      .withOpacity(0.3),
                                                  blurRadius: 8,
                                                  spreadRadius: 2,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                onWillAcceptWithDetails: (data) =>
                                    !marble.isLocked && data != marble.id,
                                onAcceptWithDetails: (details) {
                                  controller.groupMarbles(
                                    details.data,
                                    marble.id,
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Buttons Row
            Row(
              children: [
                // Reset Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.resetGame,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Reset Game',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Check Answer Button
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: controller.checkAnswer,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Check Answer',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
