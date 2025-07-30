import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/marble_model.dart';
import '../../data/models/math_problem_model.dart';
import '../../data/models/target_card_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/game_utils.dart';
import '../../core/services/dialog_service.dart';

/// Main controller for the Marble Game home screen
/// Manages game state, marble interactions, and level progression
class HomeController extends GetxController {
  // ==================== PROPERTIES ====================
  
  /// Key for accessing the play area widget
  final GlobalKey playAreaKey = GlobalKey();
  
  /// Game title displayed in the app
  final String title = AppConstants.appTitle;

  /// Current math problem to solve
  final Rx<MathProblemModel> problem = MathProblemModel(
    dividend: 24,
    divisor: 3,
  ).obs;

  /// List of all marbles in the game
  final marbles = <MarbleModel>[].obs;
  
  /// List of target cards where marble groups can be placed
  final targetCards = <TargetCardModel>[].obs;

  /// Tracks if the check answer button has been pressed
  final hasCheckedAnswer = false.obs;

  /// Current level tracking
  final currentLevel = AppConstants.startingLevel.obs;
  final totalLevels = AppConstants.totalLevels.obs;

  /// Color palette for different marble groups
  final List<Color> groupColors = [
    Colors.deepPurpleAccent,
    Colors.purple,
    Colors.red,
    Colors.redAccent,
    Colors.green,
    Colors.teal,
    Colors.brown,
  ];

  // ==================== LIFECYCLE METHODS ====================

  @override
  void onInit() {
    super.onInit();
    _initializeGame();
  }

  /// Initialize the game components
  void _initializeGame() {
    _initializeTargetCards();
    // Delay marble generation until after first frame to get accurate play area size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateMarbles();
    });
  }

  // ==================== GAME MANAGEMENT METHODS ====================

  /// Start a completely new game with random problem
  void startNewGame() {
    // Generate new random problem
    problem.value = MathProblemModel.getRandomProblem();

    // Reset game state
    _resetGameState();

    // Generate marbles based on new problem
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateMarbles();
    });
  }

  /// Progress to the next level
  void nextLevel() {
    if (currentLevel.value < totalLevels.value) {
      currentLevel.value++;
      startNewGame();

      DialogService.showLevelProgressSnackbar(
        level: currentLevel.value,
        problemText: '${problem.value.dividend} ÷ ${problem.value.divisor}',
      );
    } else {
      // Game completed - show completion dialog
      DialogService.showGameCompletionDialog(
        onPlayAgain: () {
          currentLevel.value = AppConstants.startingLevel;
          startNewGame();
        },
      );
    }
  }

  /// Reset the current game to initial state
  void resetGame() {
    _resetGameState();
    _generateMarbles();
    targetCards.refresh();
  }

  /// Reset game state without generating new problem
  void _resetGameState() {
    hasCheckedAnswer.value = false;
    _clearAllGroups();
    _resetTargetCards();
  }

  /// Clear all marble groups and assignments
  void _clearAllGroups() {
    final updates = <MarbleModel>[];
    for (var marble in marbles) {
      updates.add(
        marble.copyWith(
          groupId: null,
          isGrouped: false,
          isLocked: false,
          color: Colors.blue,
        ),
      );
    }
    _updateMarbles(updates);
  }

  /// Reset all target cards to empty state
  void _resetTargetCards() {
    for (var card in targetCards) {
      card.clearGroup();
      card.isCorrect.value = false;
    }
  }

  // ==================== MARBLE MANAGEMENT METHODS ====================

  /// Update multiple marbles efficiently
  void _updateMarbles(List<MarbleModel> updates) {
    final List<MarbleModel> newList = List.from(marbles);
    for (var update in updates) {
      final index = newList.indexWhere((m) => m.id == update.id);
      if (index != -1) {
        newList[index] = update;
      }
    }
    marbles.assignAll(newList);
  }

  /// Group marbles together when dragged onto each other
  void groupMarbles(int draggedMarbleId, int targetMarbleId) {
    if (draggedMarbleId == targetMarbleId) return;

    final draggedMarble = marbles.firstWhere((m) => m.id == draggedMarbleId);
    final targetMarble = marbles.firstWhere((m) => m.id == targetMarbleId);

    // Cannot group locked marbles
    if (targetMarble.isLocked || draggedMarble.isLocked) return;

    // Determine the group ID to use
    int newGroupId = targetMarble.groupId ?? 
                     draggedMarble.groupId ?? 
                     _generateNewGroupId();

    // Collect all marble IDs that will be in the new group
    final Set<int> marbleIdsInNewGroup = _collectGroupMarbleIds(
      draggedMarble, 
      targetMarble,
    );

    // Apply grouping with flower petal positioning
    _applyGrouping(marbleIdsInNewGroup, newGroupId, targetMarble.position);
  }

  /// Collect all marble IDs that should be in the new group
  Set<int> _collectGroupMarbleIds(MarbleModel draggedMarble, MarbleModel targetMarble) {
    final Set<int> marbleIds = {};
    
    for (var marble in [draggedMarble, targetMarble]) {
      if (marble.groupId != null) {
        marbleIds.addAll(
          marbles.where((m) => m.groupId == marble.groupId).map((m) => m.id),
        );
      } else {
        marbleIds.add(marble.id);
      }
    }
    
    return marbleIds;
  }

  /// Apply grouping logic with positioning and coloring
  void _applyGrouping(Set<int> marbleIds, int groupId, Offset basePosition) {
    final groupSize = marbleIds.length;
    final Color newColor = _getGroupColor(groupSize);
    final double radius = GameUtils.calculateGroupRadius(groupSize);
    
    final updates = <MarbleModel>[];
    int index = 0;

    for (int marbleId in marbleIds) {
      final marble = marbles.firstWhere((m) => m.id == marbleId);
      final newPosition = GameUtils.calculateCircularPosition(
        basePosition: basePosition,
        radius: radius,
        index: index,
        totalMarbles: groupSize,
      );

      updates.add(
        marble.copyWith(
          groupId: groupId,
          isGrouped: true,
          position: newPosition,
          color: newColor,
        ),
      );
      index++;
    }

    _updateMarbles(updates);
  }

  /// Get appropriate color for group based on size
  Color _getGroupColor(int groupSize) {
    if (groupSize < 2) return Colors.blue;
    
    final colorIndex = min(groupSize - 2, groupColors.length - 1);
    return groupColors[colorIndex];
  }

  /// Generate a unique group ID
  int _generateNewGroupId() {
    final existingIds = marbles
        .where((m) => m.groupId != null)
        .map((m) => m.groupId!)
        .toSet();

    int newId = AppConstants.newGroupIdStart;
    while (existingIds.contains(newId)) {
      newId++;
    }
    return newId;
  }

  /// Ungroup a marble from its current group
  void ungroupMarble(int marbleId) {
    final marble = marbles.firstWhere((m) => m.id == marbleId);
    if (marble.isLocked || marble.groupId == null) return;

    final groupId = marble.groupId!;
    final groupMarbles = marbles.where((m) => m.groupId == groupId).toList();

    if (groupMarbles.length <= 2) {
      _ungroupAllMarbles(groupMarbles);
    } else {
      _ungroupSingleMarble(marble, groupMarbles);
    }
  }

  /// Ungroup all marbles when group size is 2 or less
  void _ungroupAllMarbles(List<MarbleModel> groupMarbles) {
    final updates = <MarbleModel>[];
    final Random random = Random();

    for (var groupMarble in groupMarbles) {
      updates.add(
        groupMarble.copyWith(
          groupId: null,
          isGrouped: false,
          isLocked: false,
          color: Colors.blue,
          position: groupMarble.position + Offset(
            (random.nextDouble() - 0.5) * AppConstants.ungroupOffset,
            (random.nextDouble() - 0.5) * AppConstants.ungroupOffset,
          ),
        ),
      );
    }

    _updateMarbles(updates);
  }

  /// Ungroup a single marble from a larger group
  void _ungroupSingleMarble(MarbleModel marble, List<MarbleModel> groupMarbles) {
    final updates = <MarbleModel>[];
    final Random random = Random();

    // Remove the selected marble from group
    updates.add(
      marble.copyWith(
        groupId: null,
        isGrouped: false,
        isLocked: false,
        color: Colors.blue,
        position: marble.position + Offset(
          (random.nextDouble() - 0.5) * AppConstants.ungroupOffsetLarge,
          (random.nextDouble() - 0.5) * AppConstants.ungroupOffsetLarge,
        ),
      ),
    );

    // Reorganize remaining marbles in the group
    final remainingMarbles = groupMarbles.where((m) => m.id != marble.id).toList();
    _reorganizeRemainingMarbles(remainingMarbles, updates);

    _updateMarbles(updates);
  }

  /// Reorganize remaining marbles after ungrouping
  void _reorganizeRemainingMarbles(List<MarbleModel> remainingMarbles, List<MarbleModel> updates) {
    if (remainingMarbles.isEmpty) return;

    final basePosition = remainingMarbles.first.position;
    for (int i = 0; i < remainingMarbles.length; i++) {
      updates.add(
        remainingMarbles[i].copyWith(
          position: basePosition + Offset(
            (i % 4) * AppConstants.marbleRepositionSpacing,
            (i ~/ 4) * AppConstants.marbleRepositionSpacing,
          ),
        ),
      );
    }
  }

  // ==================== MARBLE POSITIONING METHODS ====================

  /// Update marble position during drag
  void updateMarblePosition(int marbleId, Offset globalPosition) {
    _updateMarblePositionInternal(marbleId, globalPosition, false);
  }

  /// Update marble position during drag (real-time)
  void updateMarblePositionDuringDrag(int marbleId, Offset globalPosition) {
    _updateMarblePositionInternal(marbleId, globalPosition, true);
  }

  /// Internal method to handle marble position updates
  void _updateMarblePositionInternal(int marbleId, Offset globalPosition, bool isDuringDrag) {
    final marble = marbles.firstWhere((m) => m.id == marbleId);
    if (marble.isLocked) return;

    final localPosition = _convertToLocalPosition(globalPosition);
    final clampedPosition = _clampToPlayArea(localPosition);

    if (marble.groupId != null) {
      _updateGroupPosition(marble, clampedPosition);
    } else {
      _updateSingleMarblePosition(marble, clampedPosition);
    }
  }

  /// Convert global position to local play area position
  Offset _convertToLocalPosition(Offset globalPosition) {
    final RenderBox box = playAreaKey.currentContext!.findRenderObject() as RenderBox;
    return box.globalToLocal(globalPosition);
  }

  /// Clamp position within play area bounds
  Offset _clampToPlayArea(Offset localPosition) {
    final RenderBox box = playAreaKey.currentContext!.findRenderObject() as RenderBox;
    return GameUtils.clampPosition(
      position: localPosition,
      playAreaSize: box.size,
      marbleSize: AppConstants.marbleSize,
    );
  }

  /// Update position for grouped marbles
  void _updateGroupPosition(MarbleModel marble, Offset clampedPosition) {
    final groupMarbles = marbles.where((m) => m.groupId == marble.groupId).toList();
    final groupSize = groupMarbles.length;
    final double radius = GameUtils.calculateGroupRadius(groupSize);

    final updates = <MarbleModel>[];
    for (int i = 0; i < groupSize; i++) {
      final newPosition = GameUtils.calculateCircularPosition(
        basePosition: clampedPosition,
        radius: radius,
        index: i,
        totalMarbles: groupSize,
      );
      updates.add(groupMarbles[i].copyWith(position: newPosition));
    }

    _updateMarbles(updates);
  }

  /// Update position for single marble
  void _updateSingleMarblePosition(MarbleModel marble, Offset clampedPosition) {
    final updates = [marble.copyWith(position: clampedPosition)];
    _updateMarbles(updates);
  }

  // ==================== TARGET CARD METHODS ====================

  /// Assign a marble group to a target card
  void assignGroupToCard(int groupId, int cardId) {
    final targetCard = targetCards.firstWhere((card) => card.id == cardId);
    if (targetCard.hasGroup) return;

    final groupMarbles = marbles.where((m) => m.groupId == groupId).toList();
    if (groupMarbles.isEmpty) return;

    // Check if assignment is correct
    final correctCount = problem.value.dividend ~/ problem.value.divisor;
    final isCorrect = groupMarbles.length == correctCount;

    // Assign group to card
    targetCard.assignGroup(groupId);
    targetCard.isCorrect.value = isCorrect;

    // Position marbles in the card area
    _positionMarblesInCard(groupMarbles, cardId, targetCard.color);
  }

  /// Position marbles within a target card
  void _positionMarblesInCard(List<MarbleModel> groupMarbles, int cardId, Color cardColor) {
    final basePosition = GameUtils.getSnapPointForCard(cardId);
    final updates = <MarbleModel>[];

    for (int i = 0; i < groupMarbles.length; i++) {
      final marble = groupMarbles[i];
      final newPosition = GameUtils.calculateGridPosition(
        basePosition: basePosition,
        index: i,
        spacing: AppConstants.marbleSpacing,
        itemsPerRow: 4,
      );

      updates.add(
        marble.copyWith(
          color: cardColor,
          isLocked: true,
          position: newPosition,
        ),
      );
    }

    _updateMarbles(updates);
  }

  // ==================== ANSWER CHECKING METHODS ====================

  /// Check the current answer and show appropriate feedback
  void checkAnswer() {
    final (correctCards, wrongCards, emptyCards) = _evaluateCards();
    final bool allCorrect = correctCards == targetCards.length && emptyCards == 0;

    if (allCorrect) {
      _handleCorrectAnswer();
    } else {
      _handleIncorrectAnswer(correctCards, wrongCards, emptyCards);
    }
  }

  /// Evaluate the current state of all target cards
  (int, int, int) _evaluateCards() {
    int correctCards = 0;
    int wrongCards = 0;
    int emptyCards = 0;

    for (var card in targetCards) {
      if (card.hasGroup) {
        if (card.isCorrect.value) {
          correctCards++;
        } else {
          wrongCards++;
        }
      } else {
        emptyCards++;
      }
    }

    return (correctCards, wrongCards, emptyCards);
  }

  /// Handle correct answer scenario
  void _handleCorrectAnswer() {
    final problemText = '${problem.value.dividend} ÷ ${problem.value.divisor} = ${problem.value.dividend ~/ problem.value.divisor}';
    
    DialogService.showLevelCompleteDialog(
      currentLevel: currentLevel.value,
      totalLevels: totalLevels.value,
      problemText: problemText,
      onNextLevel: nextLevel,
    );
  }

  /// Handle incorrect answer scenario
  void _handleIncorrectAnswer(int correctCards, int wrongCards, int emptyCards) {
    final expectedMarbles = problem.value.dividend ~/ problem.value.divisor;
    
    DialogService.showGameSummaryDialog(
      correctCards: correctCards,
      wrongCards: wrongCards,
      emptyCards: emptyCards,
      expectedMarbles: expectedMarbles,
      onTryAgain: resetGame,
    );
  }

  // ==================== INITIALIZATION METHODS ====================

  /// Initialize target cards with predefined colors
  void _initializeTargetCards() {
    targetCards.assignAll([
      TargetCardModel(id: 0, color: Colors.orangeAccent),
      TargetCardModel(id: 1, color: Colors.blue.shade400),
      TargetCardModel(id: 2, color: Colors.green),
    ]);
  }

  /// Generate marbles based on current problem
  void _generateMarbles() {
    final playAreaSize = _getPlayAreaSize();
    final Random random = Random();
    final List<MarbleModel> newMarbles = [];

    final totalMarbles = problem.value.dividend;

    for (int i = 0; i < totalMarbles; i++) {
      final position = GameUtils.generateRandomOffset(
        maxWidth: playAreaSize.width,
        maxHeight: playAreaSize.height,
        margin: AppConstants.safeMargin,
        random1: random.nextDouble(),
        random2: random.nextDouble(),
      );

      newMarbles.add(MarbleModel(id: i, position: position));
    }

    marbles.assignAll(newMarbles);
  }

  /// Get play area size with fallback calculations
  Size _getPlayAreaSize() {
    try {
      final RenderBox? box = playAreaKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        return box.size;
      }
    } catch (e) {
      // Context not available yet, use fallback
    }

    // Fallback calculation
    final double availableWidth = Get.width - 120 - 32; // Screen - target cards - padding
    final double availableHeight = Get.height * 0.6; // 60% of screen
    return Size(availableWidth, availableHeight);
  }

  // ==================== UTILITY METHODS ====================

  /// Change to a new random problem (for testing purposes)
  void changeProblem() {
    startNewGame();
    targetCards.refresh();
  }
}