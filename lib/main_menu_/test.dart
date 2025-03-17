import 'package:flutter/material.dart';
import 'dart:math';

class AdditiveBlendingCircles extends StatefulWidget {
  @override
  _AdditiveBlendingCirclesState createState() => _AdditiveBlendingCirclesState();
}

class _AdditiveBlendingCirclesState extends State<AdditiveBlendingCircles> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double radiusFactor = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller)
      ..addListener(() {
        setState(() {
          radiusFactor = _animation.value;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomPaint(
          size: Size(200, 200),
          painter: BlendingCirclesPainter(radiusFactor),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (_controller.status == AnimationStatus.completed) {
              _controller.reverse();
            } else {
              _controller.forward();
            }
          },
          child: Text("Merge Circles"),
        ),
      ],
    );
  }
}

class BlendingCirclesPainter extends CustomPainter {
  final double radiusFactor;
  BlendingCirclesPainter(this.radiusFactor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..blendMode = BlendMode.plus;
    double baseRadius = 50;
    double spread = baseRadius * 2 * radiusFactor;

    void drawCircle(Color color, Offset center) {
      paint.color = color;
      canvas.drawCircle(center, baseRadius, paint);
    }

    drawCircle(Colors.red, Offset(size.width * 0.5, size.height * 0.5 - spread));
    drawCircle(Colors.green, Offset(size.width * 0.5 - spread, size.height * 0.5 + spread / 2));
    drawCircle(Colors.blue, Offset(size.width * 0.5 + spread, size.height * 0.5 + spread / 2));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: AdditiveBlendingCircles()),
    ),
  ));
}
