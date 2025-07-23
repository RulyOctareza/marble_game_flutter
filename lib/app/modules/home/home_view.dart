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
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${controller.problem.dividend} ÷ ${controller.problem.divisor}',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
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
                                color: card.color.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: card.isCorrect.value ? card.color : Colors.red,
                                  width: card.isCorrect.value ? 2 : 4,
                                ),
                              ),
                            );
                          },
                          onWillAccept: (groupId) => groupId != null && !card.hasGroup,
                          onAccept: (groupId) {
                            controller.assignGroupToCard(groupId, card.id);
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
                                  return GestureDetector(
                                    onDoubleTap: () {
                                      controller.ungroupMarble(marble.id);
                                    },
                                    child: Draggable<int>(
                                      data: marble.groupId ?? marble.id,
                                      feedback: Container(
                                        width: 45,
                                        height: 45,
                                        decoration: BoxDecoration(
                                          color: marble.color.withOpacity(0.7),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.3),
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                      childWhenDragging: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: marble.color.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      onDragUpdate: (details) {
                                        if (!marble.isLocked) {
                                          controller.updateMarblePositionDuringDrag(
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
                                            color: marble.groupId != null ? 
                                              Colors.white : Colors.black,
                                            width: marble.groupId != null ? 2.0 : 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                onWillAccept: (data) =>
                                    data != null && !marble.isLocked && data != marble.id,
                                onAccept: (data) {
                                  controller.groupMarbles(data, marble.id);
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

            // Check Answer Button
            SizedBox(
              width: double.infinity,
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
      ),
    );
  }
}
