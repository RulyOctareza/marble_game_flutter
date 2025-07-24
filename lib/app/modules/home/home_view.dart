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
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 80,
                              height: 120,
                              decoration: BoxDecoration(
                                color: card.hasGroup
                                    ? (controller.hasCheckedAnswer.value
                                          ? (card.isCorrect.value
                                                ? card.color.withOpacity(
                                                    0.8,
                                                  ) // Normal color if correct
                                                : card.color.withOpacity(
                                                    0.7,
                                                  )) // Red background if wrong
                                          : card.color.withOpacity(
                                              0.8,
                                            )) // Normal before check
                                    : card.color.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      controller.hasCheckedAnswer.value &&
                                          card.hasGroup
                                      ? (card.isCorrect.value
                                            ? Colors
                                                  .green // Green border if correct
                                            : Colors.red) // Red border if wrong
                                      : (candidateData.isNotEmpty &&
                                                !card.hasGroup
                                            ? Colors.white
                                            : card.hasGroup
                                            ? card.color
                                            : Colors.grey),
                                  width:
                                      controller.hasCheckedAnswer.value &&
                                          card.hasGroup
                                      ? 4 // Thicker border after check answer
                                      : (candidateData.isNotEmpty ? 3 : 2),
                                ),
                                // Add shadow for wrong answers
                                boxShadow:
                                    controller.hasCheckedAnswer.value &&
                                        card.hasGroup &&
                                        !card.isCorrect.value
                                    ? [
                                        BoxShadow(
                                          color: Colors.red.withOpacity(0.5),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Stack(
                                children: [
                                  // Main content
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (card.hasGroup) ...[
                                          // Show marble count with better styling
                                          Text(
                                            '${controller.marbles.where((m) => m.groupId == card.assignedGroupId.value).length}',
                                            style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  controller
                                                          .hasCheckedAnswer
                                                          .value &&
                                                      !card.isCorrect.value
                                                  ? Colors.white
                                                  : Colors.white,
                                            ),
                                          ),
                                          const Text(
                                            'marbles',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                          ),

                                          // Show status icons and text after check answer
                                        ] else ...[
                                          const SizedBox(height: 4),
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
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  // Big X overlay for wrong answers
                                  if (controller.hasCheckedAnswer.value &&
                                      card.hasGroup &&
                                      !card.isCorrect.value) ...[
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 4,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.red,
                                          size: 16,
                                          weight: 800,
                                        ),
                                      ),
                                    ),
                                  ],
                                  // Green check overlay for correct answers
                                  if (controller.hasCheckedAnswer.value &&
                                      card.hasGroup &&
                                      card.isCorrect.value) ...[
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 4,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.green,
                                          size: 16,
                                          weight: 800,
                                        ),
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

                  // Play Area
                  Expanded(
                    child: Container(
                      key: controller.playAreaKey,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
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
                                                  ? Colors.white
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
                                                  color: Colors.white
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
