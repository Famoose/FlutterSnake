import 'package:flutter/material.dart';

import 'direction.dart';
import 'model/game-state.dart';
import 'model/snake.dart';

class SnakePainter extends CustomPainter {
  GameState gameState;

  SnakePainter(this.gameState);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Colors.redAccent;

    List<Path> paths = [];
    // todo: fix this through right statemanagment
    if(gameState.running){
      drawSnake(gameState.size, paths);
    }
    //render
    for (var path in paths) {
      canvas.drawPath(path, paint);
    }
    var path = Path();
    canvas.drawPath(path, paint);
  }

  void drawSnake(Size size, List<Path> paths) {
    for (var tail in gameState.snake.tails) {
      var path = Path();
      Point endPoint = tail.getEndPoint();
      endPoint.adjustToSeamlessFit(tail.dir);
      bool isOverSide = false;
      switch (tail.dir.oppositDir) {
        case Direction.up:
          if (tail.start.y > endPoint.y) {
            isOverSide = true;
            path.addRect(calcRectFromTo(tail.start, Point(size, tail.start.x, size.height), WIDTH));
            path.addRect(
                calcRectFromTo(Point(size, tail.start.x, 0), endPoint, WIDTH));
          }
          break;
        case Direction.right:
          if (tail.start.x < endPoint.x) {
            isOverSide = true;
            path.addRect(calcRectFromTo(tail.start, Point(size ,0, tail.start.y), WIDTH));
            path.addRect(calcRectFromTo(Point(size, size.width, tail.start.y), endPoint, WIDTH));
          }
          break;
        case Direction.left:
          if (tail.start.x > endPoint.x) {
            isOverSide = true;
            path.addRect(calcRectFromTo(tail.start, Point(size, size.width, tail.start.y), WIDTH));
            path.addRect(
                calcRectFromTo(Point(size, 0, tail.start.y), endPoint, WIDTH));
          }
          break;
        case Direction.down:
          if (tail.start.y < endPoint.y) {
            isOverSide = true;
            path.addRect(calcRectFromTo(tail.start, Point(size, tail.start.x, 0), WIDTH));
            path.addRect(calcRectFromTo(Point(size, tail.start.x, size.height), endPoint, WIDTH));
          }
      }
      if (!isOverSide) {
        path.addRect(calcRectFromTo(tail.start, endPoint, WIDTH));
      }
      path.close();
      detectSnakeCollision(paths, path);
      paths.add(path);
    }
  }

  void detectSnakeCollision(List<Path> paths, Path path) {
    // we skip the last one because it cant collide anyway and we overlap for cosmetical reason
    for (int i = 0; i < paths.length -1; i++){
      var combine = Path.combine(PathOperation.intersect, paths[i], path);
      if (combine.computeMetrics().length > 0) {
        print("over");
        gameState.timer.cancel();
        gameState.snake.alive = false;
        gameState.running = false;
      }
    }
  }

  calcRectFromTo(Point start, Point end, double width) {
    //left right
    if (start.y == end.y) {
      return Rect.fromLTWH(start.x,
          start.y - width / 2, end.x - start.x, width);
      //up down
    } else if (start.x == end.x) {
      return Rect.fromLTWH(start.x - width / 2,
          start.y, width, end.y - start.y);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
