import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';
import 'package:psnake/game/direction.dart';
import 'package:psnake/game/model/renderable.dart';

part 'snake.g.dart';

@JsonSerializable(explicitToJson: true)
class Snake implements RenderAble {
  List<Tail> tails;
  Direction dir;
  double length;
  GameSize size;
  int blockedMoves = 0;
  bool alive = true;
  final double WIDTH;

  Snake(this.tails, this.dir, this.length, this.WIDTH);

  Snake.start(Size size, this.dir, this.length, this.WIDTH) {
    this.size = GameSize(size.width, size.height);

    tails = [
      new Tail(
          this.size,
          new Point.fromSize(this.size, size.width / 2, size.height / 2),
          dir.oppositDir,
          length,
          WIDTH)
    ];
  }

  Snake.startPoint(Size size, Point point, this.dir, this.length, this.WIDTH) {
    this.size = GameSize(size.width, size.height);

    tails = [
      new Tail(
          this.size,
          point,
          dir.oppositDir,
          length,
          WIDTH)
    ];
  }

  void setDir(Direction direction) {
    if (direction != dir && direction != dir.oppositDir && blockedMoves == 0) {
      blockedMoves = WIDTH.toInt();
      dir = direction;
      print(dir.oppositDir);
      tails.insert(
          0,
          new Tail(
              size,
              new Point.fromSize(
                  size, tails.first.start.x, tails.first.start.y),
              dir.oppositDir,
              0,
              WIDTH));
    }
  }

  void setSize(GameSize size) {
    this.size = size;
  }

  void move() {
    if (blockedMoves > 0) blockedMoves--;
    if (tails.fold(0, (value, tail) => value + tail.length) >= length) {
      tails.last.decreaseTail();
    }
    tails.first.extendTail();
    if (tails.last.length <= 0) {
      tails.removeLast();
    }
  }

  List<Path> toPaths() {
    List<Path> paths = [];
    this.tails.forEach((tail) {
      var tailPaths = tail.toPaths();
      detectSnakeCollision(paths, tailPaths);
      paths.addAll(tailPaths);
    });
    return paths;
  }

  void detectSnakeCollision(List<Path> paths, List<Path> tailPaths) {
    // we skip the last one because it cant collide anyway and we overlap for cosmetically reason
    tailPaths.forEach((path) {
      for (int i = 0; i < paths.length - 1; i++) {
        var combine = Path.combine(PathOperation.intersect, paths[i], path);
        if (combine.computeMetrics().isNotEmpty) {
          print("over");
          this.alive = false;
          return;
        }
      }
    });
    if (tails.any((tail) => tail.checkOverMaxLength())) {
      print("over");
      this.alive = false;
      return;
    }
  }

  factory Snake.fromJson(Map<String, dynamic> json) => _$SnakeFromJson(json);

  Map<String, dynamic> toJson() => _$SnakeToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Point {
  double _x;
  double _y;

  double get x => _x;

  double get y => _y;

  Point(double x, double y) {
    this._x = x;
    this._y = y;
  }

  Point.fromSize(GameSize size, double x, double y) {
    calcXOffset(size, x);
    calcYOffset(size, y);
  }

  calcYOffset(GameSize size, double y) {
    _y = y % (size.height + 1);
  }

  calcXOffset(GameSize size, double x) {
    _x = x % (size.width + 1);
  }

  adjustToSeamlessFit(Direction dir, double WIDTH) {
    switch (dir) {
      case Direction.up:
        _y -= WIDTH / 2;
        break;
      case Direction.right:
        _x += WIDTH / 2;
        break;
      case Direction.left:
        _x -= WIDTH / 2;
        break;
      case Direction.down:
        _y += WIDTH / 2;
        break;
    }
  }

  factory Point.fromJson(Map<String, dynamic> json) => _$PointFromJson(json);

  Map<String, dynamic> toJson() => _$PointToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Tail implements RenderAble {
  Point start;
  Direction dir;
  double length;
  GameSize size;
  final double WIDTH;

  Tail(this.size, this.start, this.dir, this.length, this.WIDTH);

  extendTail({double length = 1}) {
    switch (this.dir) {
      case Direction.up:
        start = new Point.fromSize(size, start.x, start.y + length);
        break;
      case Direction.right:
        start = new Point.fromSize(size, start.x - length, start.y);
        break;
      case Direction.left:
        start = new Point.fromSize(size, start.x + length, start.y);
        break;
      case Direction.down:
        start = new Point.fromSize(size, start.x, start.y - length);
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
        return new Point.fromSize(size, start.x, start.y - length);
      case Direction.right:
        return new Point.fromSize(size, start.x + length, start.y);
      case Direction.left:
        return new Point.fromSize(
          size,
          start.x - length,
          start.y,
        );
      case Direction.down:
        return new Point.fromSize(size, start.x, start.y + length);
    }
  }

  void setSize(GameSize size) {
    this.size = size;
  }

  @override
  List<Path> toPaths() {
    List<Path> paths = [];
    Point endPoint = this.getEndPoint();
    endPoint.adjustToSeamlessFit(this.dir, this.WIDTH);
    bool isOverSide = false;
    switch (this.dir.oppositDir) {
      case Direction.up:
        if (this.start.y >= endPoint.y) {
          isOverSide = true;
          paths.add(Path()
            ..addRect(calcRectFromTo(this.start,
                Point.fromSize(size, this.start.x, size.height), WIDTH)));
          paths.add(Path()
            ..addRect(calcRectFromTo(
                Point.fromSize(size, this.start.x, 0), endPoint, WIDTH)));
        }
        break;
      case Direction.right:
        if (this.start.x <= endPoint.x) {
          isOverSide = true;
          paths.add(Path()
            ..addRect(calcRectFromTo(
                this.start, Point.fromSize(size, 0, this.start.y), WIDTH)));
          paths.add(Path()
            ..addRect(calcRectFromTo(
                Point.fromSize(size, size.width, this.start.y),
                endPoint,
                WIDTH)));
        }
        break;
      case Direction.left:
        if (this.start.x >= endPoint.x) {
          isOverSide = true;
          paths.add(Path()
            ..addRect(calcRectFromTo(this.start,
                Point.fromSize(size, size.width, this.start.y), WIDTH)));
          paths.add(Path()
            ..addRect(calcRectFromTo(
                Point.fromSize(size, 0, this.start.y), endPoint, WIDTH)));
        }
        break;
      case Direction.down:
        if (this.start.y < endPoint.y) {
          isOverSide = true;
          paths.add(Path()
            ..addRect(calcRectFromTo(
                this.start, Point.fromSize(size, this.start.x, 0), WIDTH)));
          paths.add(Path()
            ..addRect(calcRectFromTo(
                Point.fromSize(size, this.start.x, size.height),
                endPoint,
                WIDTH)));
        }
    }
    if (!isOverSide) {
      paths.add(Path()..addRect(calcRectFromTo(this.start, endPoint, WIDTH)));
    }
    return paths;
  }

  calcRectFromTo(Point start, Point end, double width) {
    //left right
    if (start.y == end.y) {
      return Rect.fromLTWH(
          start.x, start.y - width / 2, end.x - start.x, width);
      //up down
    } else if (start.x == end.x) {
      return Rect.fromLTWH(
          start.x - width / 2, start.y, width, end.y - start.y);
    }
  }

  bool checkOverMaxLength() {
    if (this.dir == Direction.left || this.dir == Direction.right) {
      return this.length > size.width - WIDTH / 2;
    } else {
      return this.length > size.height - WIDTH / 2;
    }
  }

  factory Tail.fromJson(Map<String, dynamic> json) => _$TailFromJson(json);

  Map<String, dynamic> toJson() => _$TailToJson(this);
}

@JsonSerializable()
class GameSize {
  double width, height;

  GameSize(this.width, this.height);

  factory GameSize.fromJson(Map<String, dynamic> json) =>
      _$GameSizeFromJson(json);

  Map<String, dynamic> toJson() => _$GameSizeToJson(this);
}
