import 'dart:async';
import 'dart:ui';
import '../direction.dart';
import 'snake.dart';

class GameState {
  final Duration speed = Duration(milliseconds: 10);
  Timer timer;
  Snake snake;
  Size size;
  bool running = false;

  createSnake(Size size) {
    this.size = size;
    this.snake = new Snake.start(size, Direction.right, 100);
  }

  startGame(Function callback) {
    this.running = true;
    timer = Timer.periodic(speed, (_) {
      callback();
    });
  }

  gameTick() {
    snake.move();
  }

  changeDir(Direction direction) {
    if(this.running){
      snake.setDir(direction);
    }
  }
}