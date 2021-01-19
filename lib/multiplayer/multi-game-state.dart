import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:psnake/game/model/renderable.dart';
import 'package:psnake/game/model/snake.dart';
import 'package:psnake/multiplayer/abstract-connection.dart';

import '../game/direction.dart';
import '../game/model/game-state.dart';

class MultiGameState extends GameState {
  Snake otherSnake;
  AbstractConnection connection;

  MultiGameState(this.connection);

  @override
  createSnake(Size size) {
    this.size = size;
    var gamesize = GameSize(size.width, size.height);

    this.snake = new Snake.startPoint(
        this.size,
        Point.fromSize(gamesize, size.width / 8, size.height / 2),
        Direction.up,
        1,
        size.width / 40);
  }

  createOtherSnake(Size size) {
    this.size = size;
    var gamesize = GameSize(size.width, size.height);
    this.otherSnake = new Snake.startPoint(
        this.size,
        Point.fromSize(gamesize, (size.width * 7) / 8 , size.height / 2),
        Direction.up,
        1,
        size.width / 40);
  }

  @override
  gameTick(BuildContext context) {
    if (snake.alive && otherSnake.alive) {
      snake.length++;
      snake.move();
      otherSnake.length++;
      otherSnake.move();
      rules();
      connection.write(jsonEncode([snake, otherSnake]));
    } else {
      timer.cancel();
    }
  }

  @override
  bool rules() {
    //check snake
    snake.tails.forEach((tail) {
      tail.toPaths().forEach((path) {
        var combine = Path.combine(PathOperation.intersect, path,
            otherSnake.tails.first.toPaths().first);
        if (combine.computeMetrics().isNotEmpty) {
          snake.alive = false;
        }
      });
    });
    //check othersnake
    otherSnake.tails.forEach((tail) {
      tail.toPaths().forEach((path) {
        var combine = Path.combine(
            PathOperation.intersect, path, snake.tails.first.toPaths().first);
        if (combine.computeMetrics().isNotEmpty) {
          otherSnake.alive = false;
        }
      });
    });
    return true;
  }

  @override
  List<RenderAble> toRender(){
    List<RenderAble> render = super.toRender();
    render.add(otherSnake);
    return render;
  }
}
