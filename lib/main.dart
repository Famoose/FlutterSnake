import 'dart:async';
import 'dart:developer' as d;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:psnake/control.dart';
import 'package:psnake/snake-painter.dart';
import 'dart:math';

import 'direction.dart';

void main() {
  runApp(MyApp());
}

TextStyle normalTextStyle = TextStyle(
    fontSize: 14,
    fontStyle: FontStyle.normal,
    color: Colors.black,
    decoration: TextDecoration.none);

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
  GlobalKey _keyRed = GlobalKey();
  _getSizes() {
    final RenderBox renderBoxRed = _keyRed.currentContext.findRenderObject();
    final sizeRed = renderBoxRed.size;
    print("SIZE of Red: $sizeRed");
    return sizeRed;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => postBuild(context));
  }

  void postBuild(BuildContext context) {
    setState(() {
      gameState = GameState(_getSizes());
    });
    Timer.periodic(const Duration(milliseconds: 10), (_) {
      setState(() {
        gameState.snake.move();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void changeDir(Direction direction) {
    gameState.snake.setDir(direction);
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
                child: Container(key: _keyRed),
              ),
              Text(
                "Debug - Tails: ",
                style: normalTextStyle,
              )
            ]))));
  }
}

class GameState {
  Snake snake;
  Size size;
  GameState(this.size) {
    snake = new Snake.start(size, Direction.right, 100);
  }
}