import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './model/game-state.dart';
import 'package:psnake/game/snake-painter.dart';
import 'package:psnake/styles/styles.dart';

import 'direction.dart';

class MySnake extends StatefulWidget {
  @override
  _MySnakeState createState() => _MySnakeState();
}

class _MySnakeState extends State<MySnake> {
  GameState gameState;
  GlobalKey _keyGameBoard = GlobalKey();

  _getSizes() {
    final RenderBox renderGameBox =
        _keyGameBoard.currentContext.findRenderObject();
    final sizeGameBox = renderGameBox.size;
    print("SIZE of GameBox: $sizeGameBox");
    return sizeGameBox;
  }

  @override
  void initState() {
    super.initState();
    gameState = GameState();
    WidgetsBinding.instance.addPostFrameCallback((_) => postBuild());
    // At some time you need to complete the future:
  }

  void postBuild() {
    setState(() {
      gameState.createSnake(_getSizes());
    });
    gameState.startGame(() {
      setState(() {
        gameState.gameTick();
      });
    });
  }

  void restartGame() {
    setState(() {
      gameState = new GameState();
    });
    postBuild();
  }

  void changeDir(Direction direction) {
    setState(() {
      gameState.changeDir(direction);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onPanUpdate: (details) {
          double offset = 6;
          if (details.delta.dx > offset) {
            changeDir(Direction.right);
          } else if (details.delta.dx < -offset) {
            changeDir(Direction.left);
          } else if (details.delta.dy < -offset) {
            changeDir(Direction.up);
          } else if (details.delta.dy > offset) {
            changeDir(Direction.down);
          }
        },
        child: Container(
            color: Colors.white,
            child: SafeArea(
                child: Stack(children: <Widget>[
              CustomPaint(
                painter: SnakePainter(this.gameState),
                child: Container(key: _keyGameBoard),
              ),
              TextOverlay(this.gameState, restartGame)
            ]))));
  }
}

class TextOverlay extends StatelessWidget {
  GameState gameState;
  Function resetGame;

  TextOverlay(this.gameState, this.resetGame);

  @override
  Widget build(BuildContext context) {
    if (gameState.running && gameState.snake.alive) {
      return Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
                child: Text(
              "Debug - length: " + gameState.snake.length.toInt().toString(),
              style: normalTextStyle,
            )),
            Flexible(
                child: Text(
              "Debug - Alive: " + gameState.snake.alive.toString(),
              style: normalTextStyle,
            ))
          ]);
    } else if (gameState.running && !gameState.snake.alive) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Your Score: " + gameState.snake.length.toInt().toString())
                ]),
            Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CupertinoButton(child: Text("Restart"), onPressed: resetGame)
                ])
          ]);
    } else {
      return Container();
    }
  }
}
