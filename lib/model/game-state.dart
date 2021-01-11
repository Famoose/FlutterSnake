import 'dart:async';
import 'dart:ui';
import '../direction.dart';
import 'goal.dart';
import 'snake.dart';

class GameState {
  final Duration speed = Duration(milliseconds: 10);
  Timer timer;
  Snake snake;
  Size size;
  bool running = false;
  List<Goal> goals = [];

  createSnake(Size size) {
    this.size = size;
    this.snake = new Snake.start(size, Direction.right, 100);
    this.goals.add(Goal(this.size));
    this.goals.add(Goal(this.size));
    this.goals.add(Goal(this.size));
    this.goals.add(Goal(this.size));
    this.goals.add(Goal(this.size));
  }

  startGame(Function callback) {
    this.running = true;
    timer = Timer.periodic(speed, (_) {
      callback();
    });
  }

  gameTick() {
    if(snake.alive){
      snake.move();
    }else{
      running = false;
      timer.cancel();
    }
  }

  changeDir(Direction direction) {
    if(this.running){
      snake.setDir(direction);
    }
  }
}