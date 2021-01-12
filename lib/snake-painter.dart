import 'package:flutter/material.dart';

import 'game/direction.dart';
import 'model/game-state.dart';
import 'model/snake.dart';

class SnakePainter extends CustomPainter {
  GameState gameState;

  SnakePainter(this.gameState);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Colors.redAccent;

    if (gameState.running) {
      List<Path> goalPaths = [];
      gameState.goals.forEach((goal) {
        var path = goal.toPath();
        goalPaths.add(goal.toPath());
        canvas.drawPath(path, paint);
      });
      var snakePaths = gameState.snake.toPaths();
      snakePaths.forEach((path) {
        canvas.drawPath(path, paint);
      });
      checkForPoints(snakePaths.first, goalPaths);
    }
  }

  checkForPoints(Path snakeHead, List<Path> goals){
    for (int i = 0; i < goals.length; i++){
      var combine = Path.combine(PathOperation.intersect, goals[i], snakeHead);
      if (combine.computeMetrics().length > 0) {
        gameState.snake.length += gameState.goals[i].points;
        gameState.goals.removeAt(i);
        gameState.newGoal();
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
