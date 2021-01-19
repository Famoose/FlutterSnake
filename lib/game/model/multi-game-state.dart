import 'dart:math';
import 'dart:ui';

import 'package:psnake/game/model/snake.dart';

import '../direction.dart';
import 'game-state.dart';

class MultiGameState extends GameState {
  Snake otherSnake;

  createOtherSnake(Size size) {
    this.size = size;
    this.otherSnake =
        new Snake.start(this.size, Direction.up, 80, size.width / 40);
  }

  @override
  bool rules() {
    return true;
  }

}
