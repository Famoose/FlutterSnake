import 'package:flutter/cupertino.dart';

import 'direction.dart';
import 'model/game-state.dart';

class SnakePainter extends CustomPainter {
  GameState gameState;

  SnakePainter(this.gameState);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = CupertinoColors.systemPink;

    if (gameState.running) {
      gameState.toRender().forEach((renderAble) {
        renderAble
            .toPaths()
            .forEach((path) {
          canvas.drawPath(path, paint);
        });
      });
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
