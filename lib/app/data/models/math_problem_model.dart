import 'dart:math';

/// Model representing a math division problem in the game
/// Contains dividend and divisor values with utility methods
class MathProblemModel {
  /// The number to be divided (e.g., 24 in "24 ÷ 3")
  final int dividend;

  /// The number to divide by (e.g., 3 in "24 ÷ 3")
  final int divisor;

  MathProblemModel({required this.dividend, required this.divisor});

  /// Get all predefined problems available in the game
  static List<MathProblemModel> getAllProblems() {
    return [
      MathProblemModel(dividend: 24, divisor: 3), // = 8
      MathProblemModel(dividend: 30, divisor: 3), // = 10
      MathProblemModel(dividend: 36, divisor: 3), // = 12
      MathProblemModel(dividend: 42, divisor: 3), // = 14
      MathProblemModel(dividend: 48, divisor: 3), // = 16
      MathProblemModel(dividend: 54, divisor: 3), // = 18
      MathProblemModel(dividend: 60, divisor: 3), // = 20
      MathProblemModel(dividend: 18, divisor: 3), // = 6
      MathProblemModel(dividend: 21, divisor: 3), // = 7
      MathProblemModel(dividend: 27, divisor: 3), // = 9
    ];
  }

  /// Get a random problem from the available problems
  static MathProblemModel getRandomProblem() {
    final problems = getAllProblems();
    final random = Random();
    return problems[random.nextInt(problems.length)];
  }

  /// Calculate the result of the division problem
  int get result => dividend ~/ divisor;
}
