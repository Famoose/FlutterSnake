import 'dart:math';
import 'dart:ui';

import 'package:psnake/model/snake.dart';

class Goal {
  Offset center;
  Size boardSize;
  double points;

  Goal(this.boardSize) {
    moveToRandomPosition();
    points = new Random().nextInt(100).toDouble();
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
