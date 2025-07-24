import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[200],

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Find the result of the division',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: EdgeInsets.only(
                  top: 8,
                  bottom: 8,
                  left: 16,
                  right: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B4CB8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5A2D6F),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${controller.problem.dividend} ÷ ${controller.problem.divisor}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        Positioned(
                          bottom: -15,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 40,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.purple,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  '=',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: Row(
                  children: [
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
                                width: 90,
                                height: 130,
                                decoration: BoxDecoration(
                                  color: card.hasGroup
                                      ? (card.isCorrect.value
                                            ? card.color.withValues(alpha: 0.8)
                                            : card.color.withValues(alpha: 0.7))
                                      : card.color.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: card.hasGroup
                                        ? (card.isCorrect.value
                                              ? Colors.green
                                              : Colors.red)
                                        : (candidateData.isNotEmpty &&
                                                  !card.hasGroup
                                              ? Colors.white
                                              : card.hasGroup
                                              ? card.color
                                              : Colors.grey),
                                    width:
                                        controller.hasCheckedAnswer.value &&
                                            card.hasGroup
                                        ? 4
                                        : (candidateData.isNotEmpty ? 3 : 2),
                                  ),

                                  boxShadow:
                                      controller.hasCheckedAnswer.value &&
                                          card.hasGroup &&
                                          !card.isCorrect.value
                                      ? [
                                          BoxShadow(
                                            color: Colors.red.withValues(
                                              alpha: 0.5,
                                            ),
                                            blurRadius: 12,
                                            spreadRadius: 4,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (card.hasGroup) ...[
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
                                                    ? Colors.red
                                                    : Colors.white,
                                              ),
                                            ),
                                            const Text(
                                              'Marbles',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white70,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
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

                                    if (card.hasGroup &&
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
                                                color: Colors.black.withValues(
                                                  alpha: 0.3,
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

                                    if (card.hasGroup &&
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
                                                color: Colors.black.withValues(
                                                  alpha: 0.3,
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
                              if (card.hasGroup) return false;

                              final marbleId = details.data;
                              final marble = controller.marbles.firstWhere(
                                (m) => m.id == marbleId,
                              );

                              return marble.groupId != null;
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
                                              color: marble.color.withValues(
                                                alpha: 0.8,
                                              ),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 3,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.4),
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
                                              color: marble.color.withValues(
                                                alpha: 0.3,
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
                                                        .withValues(alpha: 0.5),
                                                    blurRadius: 6,
                                                    spreadRadius: 1,
                                                  ),
                                                if (isHighlighted && canAccept)
                                                  BoxShadow(
                                                    color: Colors.green
                                                        .withValues(alpha: 0.3),
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

              Row(
                children: [
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
      ),
    );
  }
}
