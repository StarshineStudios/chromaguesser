import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// MAIN
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SquareHolder Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('SquareHolder Demo'),
        ),
        body: Center(
          child: SquareHolder(
            height: 150,
            padding: 10,
            velocity: 3,
          ),
        ),
      ),
    );
  }
}

// SQUARE HOLDER
class SquareHolder extends StatefulWidget {
  final double height;
  final double padding;
  final double velocity;

  SquareHolder({
    this.height = 150,
    this.padding = 10,
    this.velocity = 3,
  });

  @override
  _SquareHolderState createState() => _SquareHolderState();
}

class _SquareHolderState extends State<SquareHolder> with SingleTickerProviderStateMixin {
  late List<AnimatedSquare> _squares;
  late double _squareSize;
  late double _squareWidthWithPadding;
  late double screenWidth;
  late int numSquares;
  final _random = Random();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        screenWidth = MediaQuery.of(context).size.width;
        _initializeSquares();
        _startAnimation();
      });
    });
  }

  void _initializeSquares() {
    _squareSize = widget.height - 2 * widget.padding;
    _squareWidthWithPadding = _squareSize + widget.padding;
    screenWidth = MediaQuery.of(context).size.width; // Make sure screenWidth is initialized
    numSquares = (screenWidth / _squareWidthWithPadding).ceil() + 1;

    _squares = List.generate(numSquares, (i) {
      return AnimatedSquare(
        size: _squareSize,
        padding: widget.padding,
        position: i * _squareWidthWithPadding - numSquares * _squareWidthWithPadding,
        color: Color.fromARGB(
          255,
          _random.nextInt(256),
          _random.nextInt(256),
          _random.nextInt(256),
        ),
        label: i + 1,
      );
    });
  }

  void _startAnimation() {
    _timer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      setState(() {
        if (widget.velocity > 0) {
          // Moving right
          for (var i = 0; i < _squares.length; i++) {
            var square = _squares[i];
            square.position += widget.velocity;

            if (square.position > screenWidth) {
              // Move square to the end of the list
              square.position = _squares[getLeftmostSquareIndex()].position - _squareWidthWithPadding;
            }
          }
        } else {
          // Moving left
          for (var i = _squares.length - 1; i >= 0; i--) {
            var square = _squares[i];
            square.position += widget.velocity;

            if (square.position < -_squareSize) {
              // Move square to the start of the list
              square.position = _squares[getRightmostSquareIndex()].position + _squareWidthWithPadding;
            }
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      color: Colors.blue,
      child: Stack(
        children: _squares.map((square) => square.getWidget()).toList(),
      ),
    );
  }

  int getLeftmostSquareIndex() {
    double lowestPosition = _squares[0].position;
    int index = 0;
    for (int i = 1; i < _squares.length; i++) {
      if (_squares[i].position < lowestPosition) index = i;
    }
    return index;
  }

  int getRightmostSquareIndex() {
    double highestPosition = _squares[0].position;
    int index = 0;
    for (int i = 1; i < _squares.length; i++) {
      if (_squares[i].position > highestPosition) index = i;
    }
    return index;
  }
}

class AnimatedSquare {
  final double size;
  final double padding;
  final Color color;
  final int label;
  double position;

  AnimatedSquare({
    required this.size,
    required this.padding,
    required this.position,
    required this.color,
    required this.label,
  });

  Widget getWidget() {
    return Positioned(
      top: padding,
      left: position,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            '${label}',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
