import 'package:flutter/cupertino.dart';
import 'package:psnake/game/direction.dart';
import 'package:psnake/game/model/game-state.dart';
import 'package:psnake/singleplayer/single-game-state.dart';
import 'package:psnake/game/snake-painter.dart';

import '../router.dart';

class SinglePlayerGamePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SinglePlayerSnake();
  }
}

class SinglePlayerSnake extends StatefulWidget {
  @override
  _SinglePlayerSnakeState createState() => _SinglePlayerSnakeState();
}

class _SinglePlayerSnakeState extends State<SinglePlayerSnake> {
  SingleGameState gameState;
  GlobalKey _keyGameBoard = GlobalKey();
  double offset = 7;

  @override
  void dispose() {
    gameState.timer.cancel();
    super.dispose();
  }

  Size _getSizes() {
    final RenderBox renderGameBox =
        _keyGameBoard.currentContext.findRenderObject();
    final sizeGameBox = renderGameBox.size;
    print("SIZE of GameBox: $sizeGameBox");
    return sizeGameBox;
  }

  @override
  void initState() {
    super.initState();
    gameState = SingleGameState();
    WidgetsBinding.instance.addPostFrameCallback((_) => postBuild());
  }

  void postBuild() {
    setState(() {
      Size size = _getSizes();
      offset = size.height * size.width * 0.000025;
      gameState.createSnake(size);
      gameState.createGoals(5);
    });
    gameState.startGame(() {
      setState(() {
        gameState.gameTick(context);
      });
    });
  }

  void restartGame() {
    setState(() {
      gameState = new SingleGameState();
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
    return Stack(children: <Widget>[
      GestureDetector(

          onPanUpdate: (details) {
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
          child: SafeArea(
              child: Stack(children: <Widget>[
            CustomPaint(
              painter: SnakePainter(this.gameState),
              child: Container(key: _keyGameBoard),
            ),
          ]))),
      TextOverlay(gameState, restartGame)
    ]);
  }
}

class TextOverlay extends StatelessWidget {
  GameState gameState;
  Function resetGame;

  TextOverlay(this.gameState, this.resetGame);

  @override
  Widget build(BuildContext context) {
    if (gameState.running && !gameState.snake.alive) {
      return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            leading: CupertinoButton(
                child: Center(child: Icon(CupertinoIcons.back)),
                onPressed: () => Navigator.pushNamed(context, HomeViewRoute)),
          ),
          child: Center(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                Text(
                    "Your Score: " + gameState.snake.length.toInt().toString()),
                CupertinoButton(child: Text("Restart"), onPressed: resetGame)
              ])));
    } else {
      return Container();
    }
  }
}
