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
            //
            // 1. WIDGET SOAL MATEMATIKA
            // Menampilkan data dari controller
            //
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              //
              // Menampilkan data dari controller
              //
              child: Text(
                '${controller.problem.dividend} ÷ ${controller.problem.divisor}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 24),
            //
            // 2. AREA UTAMA (KARTU TARGET & AREA PERMAINAN)
            //

            // SISI KIRI: KARTU-KARTU TARGET
            Expanded(
              child: Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(controller.targetCards.length, (
                      index,
                    ) {
                      final card = controller.targetCards[index];
                      return DragTarget<int>(
                        builder: (context, candidateData, rejectedData) {
                          return Obx(
                            () => Container(
                              width: 80,
                              height: 120,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: card.color.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      card.isCorrect.value ||
                                          card.marbles.isEmpty
                                      ? card.color
                                      : Colors.red,
                                  width:
                                      card.isCorrect.value ||
                                          card.marbles.isEmpty
                                      ? 2
                                      : 4,
                                ),
                              ),
                              child: Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: card.marbles.map((marble) {
                                  return GestureDetector(
                                    onTap: () {
                                      controller.returnMarbleToPlayArea(
                                        marble.id,
                                        card.id,
                                      );
                                    },
                                    child: Container(
                                      width: 15,
                                      height: 15,
                                      decoration: const BoxDecoration(
                                        color: Colors.deepPurple,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                        onWillAcceptWithDetails: (data) => true,
                        onAcceptWithDetails: (details) {
                          controller.addMarbleToTarget(details.data, card.id);
                        },
                      );
                    }),
                  ),

                  const SizedBox(width: 16),
                  //
                  // SISI KANAN: AREA PERMAINAN
                  //
                  Expanded(
                    child: Container(
                      key: controller.playAreaKey,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Obx(
                        () => Stack(
                          children: controller.marbles.map((marble) {
                            return Positioned(
                              left: marble.position.dx,
                              top: marble.position.dy,
                              child: Draggable<int>(
                                data: marble.id,
                                feedback: Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.7),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                                // Widget yang ditinggal di posisi asal saat di-drag
                                childWhenDragging: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple.withValues(
                                      alpha: 0.2,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                // Fungsi yang dipanggil saat drag selesai (jari diangkat)
                                onDragEnd: (details) {
                                  controller.updateMarblePosition(
                                    marble.id,
                                    details.offset,
                                  );
                                },
                                // Widget asli yang terlihat saat tidak di-drag
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.fromBorderSide(
                                      BorderSide(
                                        color: Colors.black,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            //
            // 3. TOMBOL CEK JAWABAN
            //
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
