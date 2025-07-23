class MathProblem {
  final int dividend;

  final int divisor;

  MathProblem({required this.dividend, required this.divisor});

  // Getter gawe ngitung jawaban teko soal otomatis
  int get result => dividend ~/ divisor;
}
