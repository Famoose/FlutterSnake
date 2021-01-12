import 'dart:math';
import 'dart:ui';

import 'snake.dart';

class Goal {
  Offset center;
  Size boardSize;
  double points;
  final double WIDTH;
  Goal(this.boardSize, this.WIDTH) {
    moveToRandomPosition();
    points = 1 / WIDTH * 1000;
  }

  moveToRandomPosition() {
    var rng = new Random();
    center = Offset(rng.nextInt(boardSize.width.toInt()).toDouble(),
        rng.nextInt(boardSize.height.toInt()).toDouble());
  }

  Path toPath() {
    var path = Path();
    path.addRect(Rect.fromCenter(center: center, width: WIDTH, height: WIDTH));
    return path;
  }
}
