import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:psnake/game/model/renderable.dart';

import '../../app-state-model.dart';
import '../direction.dart';
import 'snake.dart';

abstract class GameState{
  final Duration speed = Duration(milliseconds: 10);
  Timer timer;
  Snake snake;
  Size size;
  bool running = false;

  createSnake(Size size) {
    this.size = size;
    this.snake = new Snake.start(this.size, Direction.up, 80, size.width/40);
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
      rules();
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

  List<RenderAble> toRender(){
    return [snake];
  }

  bool rules();
}
