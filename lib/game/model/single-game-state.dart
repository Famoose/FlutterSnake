import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:psnake/game/model/renderable.dart';

import 'game-state.dart';
import 'goal.dart';

class SingleGameState extends GameState{
  List<Goal> goals = [];

  newGoal() {
    this.goals.add(Goal(this.size, new Random().nextInt(40).toDouble()));
  }

  createGoals(int number) {
    for(int i = 0; i < number; i++){
      newGoal();
    }
  }

  checkForGoals(){
    goals.forEach((goal) {
      var combine = Path.combine(PathOperation.intersect,  goal.toPath(), snake.tails.first.toPaths().first);
      if (combine.computeMetrics().isNotEmpty) {
        goals.remove(goal);
        snake.length += goal.points;
        newGoal();
      }
    });
  }

  @override
  List<RenderAble> toRender(){
    List<RenderAble> render = super.toRender();
    render.addAll(goals);
    return render;
  }

  @override
  bool rules() {
    checkForGoals();
    return true;
  }
}