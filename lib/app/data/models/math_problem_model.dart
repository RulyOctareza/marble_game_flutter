class MathProblemModel {
  final int dividend;

  final int divisor;

  MathProblemModel({required this.dividend, required this.divisor});

  // Getter gawe ngitung jawaban teko soal otomatis
  int get result => dividend ~/ divisor;
}
