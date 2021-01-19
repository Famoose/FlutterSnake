import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:psnake/game/direction.dart';
import 'package:psnake/game/model/game-state.dart';
import 'package:psnake/game/model/multi-game-state.dart';
import 'package:psnake/game/model/snake.dart';
import 'package:psnake/game/snake-painter.dart';
import 'package:psnake/multiplayer/abstract-connection.dart';

import '../router.dart';

class MultiplayerPlayerGamePage extends StatelessWidget {
  final DeviceType deviceType;

  const MultiplayerPlayerGamePage({this.deviceType});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(child: MySocketConnector(deviceType: deviceType));
  }
}

class MySocketConnector extends StatefulWidget {
  final DeviceType deviceType;

  MySocketConnector({this.deviceType});

  @override
  _MySocketConnectorState createState() => _MySocketConnectorState();
}

class _MySocketConnectorState extends State<MySocketConnector> {
  ConnectionHandler connectionHandler;

  @override
  void initState() {
    connectionHandler = new ConnectionHandler(widget.deviceType);
    super.initState();
  }

  @override
  void dispose() {
    connectionHandler.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: connectionHandler.init(),
    builder: (context, snapshot) {
      return MultiPlayerSnake(connectionHandler);
    });
  }
}

class MultiPlayerSnake extends StatefulWidget {

  AbstractConnection connectionHandler;
  MultiPlayerSnake(this.connectionHandler);

  @override
  _MultiPlayerSnakeState createState() => _MultiPlayerSnakeState();
}

class _MultiPlayerSnakeState extends State<MultiPlayerSnake> {
  MultiGameState gameState;
  GlobalKey _keyGameBoard = GlobalKey();

  @override
  void dispose(){
    gameState.timer.cancel();
    super.dispose();
  }

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
    gameState = MultiGameState();
    WidgetsBinding.instance.addPostFrameCallback((_) => postBuild());
  }

  void postBuild() {
    setState(() {
      gameState.createSnake(_getSizes());
      gameState.createOtherSnake(_getSizes());
    });
    if(widget.connectionHandler.isServer()){
      gameState.startGame(() {
        setState(() {
          if(gameState.snake.alive || gameState.otherSnake.alive){
            gameState.snake.move();
            gameState.otherSnake.move();
            widget.connectionHandler.write(jsonEncode([gameState.snake, gameState.otherSnake]));
          }else{
            gameState.timer.cancel();
          }
        });
      });
      widget.connectionHandler.onData = (data) {
        Direction dir = fromString(data);
        gameState.otherSnake.setDir(dir);
      };
    }else{
      widget.connectionHandler.onData = (data) {
        var snake = jsonDecode(data);
        setState(() {
          gameState.running = true;
          gameState.snake = Snake.fromJson(snake[0]);
          gameState.otherSnake = Snake.fromJson(snake[1]);
        });
      };
    }
  }

  void restartGame() {
    setState(() {
      gameState = new MultiGameState();
    });
    postBuild();
  }

  void changeDir(Direction direction) {
    setState(() {
      if(widget.connectionHandler.isServer()){
        gameState.changeDir(direction);
      }else{
        widget.connectionHandler.write(direction.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onPanUpdate: (details) {
          double offset = 7;
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
            color: CupertinoColors.white,
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
                    "Debug - length: " + gameState.snake.length.toInt().toString()
                )),
            Flexible(
                child: Text(
                    "Debug - Alive: " + gameState.snake.alive.toString()
                ))
          ]);
    } else if (gameState.running && !gameState.snake.alive) {
      return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            leading: CupertinoButton(
                child: Center(child:Icon(CupertinoIcons.back)),
                onPressed: () => Navigator.pushNamed(context, HomeViewRoute)),
          ),
          child: Center(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Your Score: " + gameState.snake.length.toInt().toString()),
                    CupertinoButton(child: Text("Restart"), onPressed: resetGame)
                  ])));
    } else {
      return Container();
    }
  }
}

