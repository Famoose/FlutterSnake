
import 'dart:math';

import 'package:flutter/material.dart';

class MyPainter extends StatefulWidget {
  @override
  _MyPainterState createState() => _MyPainterState();

}

class _MyPainterState extends State<MyPainter> with TickerProviderStateMixin {
  double _sides = 6;
  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    );

    Tween<double> _rotationTween = Tween(begin: -pi, end: pi);

    animation = _rotationTween.animate(controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.repeat();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Lines'),
        ),
        body:   AnimatedBuilder(
          animation: animation,
          builder: (context, snapshot) {
            return CustomPaint(
              painter: ShapePainter(_sides, animation.value),
              child: Container(),
            );
          },
        )
    );
  }
}

class ShapePainter extends CustomPainter {
  final double sides;
  final double radians;
  ShapePainter(this.sides, this.radians);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    var radius = 24;

    var path = Path();
    var angle = (pi * 2) / sides;

    Offset center = Offset(size.width / 2, size.height / 2);

    Offset startPoint = Offset(radius * cos(0.0), radius * sin(0.0));

    path.moveTo(startPoint.dx + center.dx, startPoint.dy + center.dy);

    for (int i = 1; i <= sides; i++) {
      double x = radius * cos(radians + angle * i) + center.dx;
      double y = radius * sin(radians + angle * i) + center.dy;
      path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
