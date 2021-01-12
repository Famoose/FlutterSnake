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
    WidgetsBinding.instance.addPostFrameCallback((_) => postBuild(context));
    // At some time you need to complete the future:
  }

  void postBuild(BuildContext context) {
    setState(() {
      gameState.createSnake(_getSizes());
    });
    gameState.startGame(() {
      setState(() {
        gameState.gameTick();
      });
    });
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
          double offset = 5;
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
                  TextOverlay(this.gameState)
                ]))));
  }
}

class TextOverlay extends StatelessWidget {
  GameState gameState;

  TextOverlay(this.gameState);

  @override
  Widget build(BuildContext context) {
    if (gameState.running) {
      return Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
                child: Text(
                  "Debug - length: " + gameState.snake.length.toString(),
                  style: normalTextStyle,
                )),
            Flexible(
                child: Text(
                  "Debug - Alive: " + gameState.snake.alive.toString(),
                  style: normalTextStyle,
                ))
          ]);
    } else {
      return Container();
    }
  }
}
