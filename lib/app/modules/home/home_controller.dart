import 'package:get/get.dart';
import 'package:marble_game/app/data/models/math_problem_model.dart';

class HomeController extends GetxController {
  final String title = "Marble Grouping Game";

  final problem = MathProblem(dividend: 24, divisor: 3);
}
