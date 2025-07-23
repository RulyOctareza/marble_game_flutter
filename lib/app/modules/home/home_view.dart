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
                color: Colors.white.withOpacity(0.3),
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
                    children: List.generate(3, (index) {
                      final colors = [Colors.red, Colors.yellow, Colors.green];
                      return Container(
                        width: 80,
                        height: 100,
                        decoration: BoxDecoration(
                          color: colors[index].withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors[index], width: 2),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(width: 16),
                  //
                  // SISI KANAN: AREA PERMAINAN
                  // Kita gunakan Stack agar bisa menumpuk kelereng di koordinat bebas
                  //
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Stack(children: []),
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
                onPressed: () {
                  // Logika pengecekan akan ditambahkan di sini
                },
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
