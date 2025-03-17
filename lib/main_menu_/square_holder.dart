import 'dart:async';
import 'package:colorguesser/constants.dart';
import 'package:colorguesser/main_menu_/animated_square.dart';
import 'package:flutter/material.dart';
import 'package:colornames/colornames.dart';

// SQUARE HOLDER
class SquareHolder extends StatefulWidget {
  final double height;
  final double padding;
  final double velocity;
  final Color biasColor;

  const SquareHolder({
    super.key,
    this.height = 150,
    this.padding = 10,
    this.velocity = 3,
    required this.biasColor,
  });

  @override
  State<SquareHolder> createState() => _SquareHolderState();
}

class _SquareHolderState extends State<SquareHolder> with SingleTickerProviderStateMixin {
  final List<AnimatedSquare> _squares = <AnimatedSquare>[];
  late double _squareSize;
  late double _squareWidthWithPadding;
  late double screenWidth;
  late int numSquares;
  // final _random = Random();
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
    numSquares = (screenWidth / _squareWidthWithPadding).ceil() + 1 + 1; //1 for safety, second 1 should be modified to add extra colors if wanted

    int appropriateDistance = (150 * 255 / (widget.biasColor.red + widget.biasColor.green + widget.biasColor.blue)).round();
    if (widget.velocity > 0) {
      for (var i = numSquares - 1; i >= 0; i--) {
        _squares.add(
          AnimatedSquare(
            size: _squareSize,
            padding: widget.padding,
            position: i * _squareWidthWithPadding,
            color: getRandomColor(widget.biasColor, distance: appropriateDistance),
            label: i + 1,
          ),
        );
        for (int j = 0; j < _squares.length - 1; j++) {
          if (_squares[j].color.colorName == _squares[_squares.length - 1].color.colorName) {
            i++;
            _squares.removeLast();
            // print('repeat deleted');
          }
        }
      }
    } else {
      for (var i = 0; i < numSquares; i++) {
        _squares.add(
          AnimatedSquare(
            size: _squareSize,
            padding: widget.padding,
            position: i * _squareWidthWithPadding,
            color: getRandomColor(widget.biasColor, distance: appropriateDistance),
            label: i + 1,
          ),
        );
        for (int j = 0; j < _squares.length - 1; j++) {
          if (_squares[j].color == _squares[_squares.length - 1].color) {
            i--;
            _squares.removeLast();
            // print('repeat deleted');
          }
        }
      }
    }
    // _squares = List.generate(numSquares, (i) {
    //   return
    // });
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
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
      color: lightColor,
      child: Stack(
        children: _squares.map((square) => square.getWidget(context)).toList(),
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
