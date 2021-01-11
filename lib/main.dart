import 'dart:async';
import 'dart:developer' as d;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psnake/control.dart';
import 'package:psnake/snake-painter.dart';
import 'package:psnake/styles/styles.dart';
import 'dart:math';

import 'direction.dart';
import 'model/app-state-model.dart';
import 'model/game-state.dart';

void main() {
  return runApp(
    ChangeNotifierProvider<AppStateModel>(
      create: (_) => AppStateModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
      ),
      home: Scaffold(body: MySnake()),
    );
  }
}

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
              "Debug - lenght: " + gameState.snake.length.toString(),
              style: normalTextStyle,
            )),
            Flexible(
                child: Text(
              "Debug - Death: " + gameState.snake.alive.toString(),
              style: normalTextStyle,
            ))
          ]);
    } else {
      return Container();
    }
  }
}
