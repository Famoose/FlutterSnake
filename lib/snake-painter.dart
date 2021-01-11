import 'package:flutter/material.dart';

import 'direction.dart';
import 'main.dart';

const double WIDTH = 10;

class Snake {
  List<Tail> tails;
  Direction dir;
  double length;
  Size size;
  int blockedMoves;

  Snake(this.tails, this.dir, this.length);

  Snake.start(this.size, this.dir, this.length) {
    tails = [new Tail(size, new Point(size, 0, 0), dir.oppositDir, length)];
  }

  void setDir(Direction direction) {
    if (direction != dir && direction != dir.oppositDir && blockedMoves == 0) {
      blockedMoves = WIDTH.toInt();
      dir = direction;
      print(dir.oppositDir);
      tails.insert(
          0,
          new Tail(size, new Point(size, tails.first.start.x, tails.first.start.y),
              dir.oppositDir, 0));
    }
  }
  void setSize(Size size){
    this.size = size;
  }

  void move() {
    if (blockedMoves > 0) blockedMoves--;
    tails.first.extendTail();
    tails.last.decreaseTail();
    if (tails.last.length <= 0) {
      tails.removeLast();
    }
  }
}

class Point {
  double _x;
  double _y;
  double get x => _x;
  double get y => _y;

  Point(Size size, double x, double y){
    calcXOffset(size, x);
    calcYOffset(size, y);
  }

  calcYOffset(Size size, double y) {
    _y =   y % (size.height + 1);
  }

  calcXOffset(size, double x) {
    _x = x % (size.width + 1);
  }
}

class Tail {
  Point start;
  Direction dir;
  double length;
  Size size;

  Tail(this.size, this.start, this.dir, this.length);

  extendTail({double length = 1}) {
    switch (this.dir) {
      case Direction.up:
        start = new Point(size, start.x, start.y + length);
        break;
      case Direction.right:
        start = new Point(size, start.x - length, start.y);
        break;
      case Direction.left:
        start = new Point(size, start.x + length, start.y);
        break;
      case Direction.down:
        start = new Point(size, start.x, start.y - length);
        break;
    }
    this.length += length;
  }

  decreaseTail({double length = 1}) {
    this.length -= length;
  }

  Point getEndPoint() {
    switch (this.dir) {
      case Direction.up:
        return new Point(size, start.x, start.y - length);
      case Direction.right:
        return new Point(size, start.x + length, start.y);
      case Direction.left:
        return new Point(size,
          start.x - length,
          start.y,
        );
      case Direction.down:
        return new Point(size, start.x, start.y + length);
    }
  }

  void setSize(Size size){
    this.size = size;
  }
}

class SnakePainter extends CustomPainter {
  GameState gameState;

  SnakePainter(this.gameState);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Colors.redAccent;
    //gameState.snake.setSize(size);

    List<Path> paths = [];
    if(gameState.snake != null){
      drawSnake(size, paths);
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
      //path.moveTo(
      //    calcXOffset(size, tail.start.x), calcYOffset(size, tail.start.y));
      //check for over side
      bool isOverSide = false;
      switch (tail.dir.oppositDir) {
        case Direction.up:
          if (tail.start.y > endPoint.y) {
            isOverSide = true;
            path.addRect(calcRectFromTo(tail.start, Point(size, tail.start.x, size.height), WIDTH));
            path.addRect(
                calcRectFromTo(Point(size, tail.start.x, 0), endPoint, WIDTH));
            //path.lineTo(calcXOffset(size, tail.start.x), size.height);
            //path.moveTo(calcXOffset(size, tail.start.x), 0);
          }
          break;
        case Direction.right:
          if (tail.start.x < endPoint.x) {
            isOverSide = true;
            path.addRect(calcRectFromTo(tail.start, Point(size ,0, tail.start.y), WIDTH));
            path.addRect(calcRectFromTo(Point(size, size.width, tail.start.y), endPoint, WIDTH));
            //path.lineTo(0, calcYOffset(size, tail.start.y));
            //path.moveTo(size.width, calcYOffset(size, tail.start.y));
          }
          break;
        case Direction.left:
          if (tail.start.x > endPoint.x) {
            isOverSide = true;
            path.addRect(calcRectFromTo(tail.start, Point(size, size.width, tail.start.y), WIDTH));
            path.addRect(
                calcRectFromTo(Point(size, 0, tail.start.y), endPoint, WIDTH));
            //path.lineTo(size.width, calcYOffset(size, tail.start.y));
            //path.moveTo(0, calcYOffset(size, tail.start.y));
          }
          break;
        case Direction.down:
          if (tail.start.y < endPoint.y) {
            isOverSide = true;
            path.addRect(calcRectFromTo(tail.start, Point(size, tail.start.x, 0), WIDTH));
            path.addRect(calcRectFromTo(Point(size, tail.start.x, size.height), endPoint, WIDTH));
            //path.lineTo(calcXOffset(size, tail.start.x), 0);
            //path.moveTo(calcXOffset(size, tail.start.x), size.height);
          }
      }
      if (!isOverSide) {
        path.addRect(calcRectFromTo(tail.start, endPoint, WIDTH));
      }
      path.close();
      paths.forEach((cpath) {
        var combine = Path.combine(PathOperation.intersect, cpath, path);
        if (combine.computeMetrics().length > 0) {
          print("over");
        }
      });
      paths.add(path);
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
