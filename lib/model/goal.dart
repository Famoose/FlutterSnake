import 'dart:math';
import 'dart:ui';

import 'package:psnake/model/snake.dart';

class Goal {
  Offset center;
  Size boardSize;

  Goal(this.boardSize) {
    moveToRandomPosition();
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
