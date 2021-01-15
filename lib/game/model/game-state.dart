import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../app-state-model.dart';
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
    this.snake = new Snake.start(this.size, Direction.up, 80, size.width/40);
    newGoal();
    newGoal();
    newGoal();
    newGoal();
    newGoal();
  }

  newGoal() {
    this.goals.add(Goal(this.size, new Random().nextInt(40).toDouble()));
  }

  startGame(Function callback) {
    this.running = true;
    timer = Timer.periodic(speed, (_) {
      callback();
    });
  }

  gameTick(BuildContext context) {
    if(snake.alive){
      snake.move();
    }else{
      timer.cancel();
      final model = Provider.of<AppStateModel>(context, listen: false);
      model.addScore(this.snake.length);
    }
  }

  changeDir(Direction direction) {
    if(this.running){
      snake.setDir(direction);
    }
  }
}