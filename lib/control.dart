import 'package:flutter/material.dart';

import 'direction.dart';

class MyControlPanel extends StatelessWidget {
  void Function(Direction) update;

  MyControlPanel(this.update);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
                onTap: () {
                  print("guest");
                  update(Direction.up);
                },
                child: Container(padding: EdgeInsets.all(100)))
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
                onTap: () {
                  update(Direction.left);
                },
                child: Container()),
            Padding(padding: new EdgeInsets.all(10.0)),
            GestureDetector(
                onTap: () {
                  update(Direction.right);
                },
                child: Container())
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
                onTap: () {
                  update(Direction.down);
                },
                child: Container())
          ],
        ),
      ],
    );
  }
}