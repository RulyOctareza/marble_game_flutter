/// App-wide constants for the Marble Game
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  /// Game configuration constants
  static const int totalLevels = 10;
  static const int startingLevel = 1;
  static const int newGroupIdStart = 1000;

  /// UI dimension constants
  static const double marbleSize = 40.0;
  static const double feedbackMarbleSize = 50.0;
  static const double targetCardWidth = 65.0;
  static const double targetCardHeight = 120.0;
  static const double marbleRadius = 20.0;
  static const double safeMargin = 20.0;
  static const double groupRadiusBase = 14.0;
  static const double groupRadiusMultiplier = 2.5;
  static const double marbleSpacing = 35.0;
  static const double ungroupOffset = 60.0;
  static const double ungroupOffsetLarge = 80.0;
  static const double marbleRepositionSpacing = 15.0;

  /// Animation durations
  static const Duration cardAnimationDuration = Duration(milliseconds: 300);
  static const Duration marbleAnimationDuration = Duration(milliseconds: 200);
  static const Duration snackbarDuration = Duration(seconds: 3);
  static const Duration shortSnackbarDuration = Duration(seconds: 2);

  /// UI styling constants
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 20.0;
  static const double borderRadiusXLarge = 30.0;
  static const double shadowBlurRadius = 2.0;
  static const double shadowSpreadRadius = 1.0;
  static const double highlightShadowBlur = 8.0;
  static const double highlightShadowSpread = 2.0;

  /// Game text constants
  static const String appTitle = "Marble Grouping Game";
  static const String gameInstruction = "Find the result of the division";
  static const String newProblemButton = "New Problem";
  static const String resetGroupsButton = "Reset Groups";
  static const String checkAnswerButton = "Check Answer";
  static const String dropGroupHere = "Drop\ngroup here";
  static const String marblesLabel = "Marbles";
  static const String nextLevelButton = "Next Level";
  static const String finishGameButton = "Finish Game";
  static const String stayHereButton = "Stay Here";
  static const String continueButton = "Continue";
  static const String tryAgainButton = "Try Again";
  static const String playAgainButton = "Play Again";
  static const String gameResetTitle = "Game Reset";
  static const String perfectTitle = "Perfect! 🎉";
  static const String gameSummaryTitle = "Game Summary";
  static const String congratulationsTitle = "🎉 Congratulations!";
  static const String gameCompletedMessage = "You have completed all levels!";
}