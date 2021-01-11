import 'dart:ui';

import '../direction.dart';

const double WIDTH = 10;

class Snake {
  List<Tail> tails;
  Direction dir;
  double length;
  Size size;
  int blockedMoves = 0;
  bool alive = true;

  Snake(this.tails, this.dir, this.length);

  Snake.start(this.size, this.dir, this.length) {
    tails = [new Tail(size, new Point(size, size.width/2, size.height/2), dir.oppositDir, length)];
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

  adjustToSeamlessFit(Direction dir) {
    switch (dir) {
      case Direction.up:
        _y -= WIDTH/2;
        break;
      case Direction.right:
        _x += WIDTH/2;
        break;
      case Direction.left:
        _x -= WIDTH/2;
        break;
      case Direction.down:
        _y += WIDTH/2;
        break;
    }
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