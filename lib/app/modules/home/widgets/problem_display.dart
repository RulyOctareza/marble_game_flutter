import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

/// Widget for displaying the math problem with decorative styling
class ProblemDisplay extends StatelessWidget {
  final int dividend;
  final int divisor;

  const ProblemDisplay({
    super.key,
    required this.dividend,
    required this.divisor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Main problem container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                  border: Border.all(
                    color: const Color(0xFF5A2D6F),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 66, 33, 123),
                      blurRadius: AppConstants.shadowBlurRadius,
                      spreadRadius: AppConstants.shadowSpreadRadius,
                      offset: const Offset(4, 5),
                    ),
                  ],
                ),
                child: Text(
                  '$dividend ÷ $divisor',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Equals sign positioned at center bottom
              Positioned(
                bottom: -25,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 90,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5A2D6F),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 66, 33, 123)
                              .withValues(alpha: 1),
                          blurRadius: AppConstants.shadowBlurRadius,
                          spreadRadius: 2,
                          offset: const Offset(1, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '=',
                        style: TextStyle(
                          fontSize: 30,
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
    );
  }
}