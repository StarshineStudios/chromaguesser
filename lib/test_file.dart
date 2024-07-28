import 'dart:async';
import 'dart:math' as math;
import 'dart:math';
import 'package:colorguesser/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:colornames/colornames.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

// MAIN
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    double elementToPaddingRatio = 3 / 1;

    //first number is number of paddings, second is number of elements
    double paddingHeight = height / (5 * elementToPaddingRatio + 6);
    double elementHeight = elementToPaddingRatio * paddingHeight;

    double holderAngle = math.pi / 120;
    double compensationScale = 1.2;

    return MaterialApp(
      title: 'SquareHolder Demo',
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 235, 227, 213),
        // appBar: AppBar(
        //   title: Text('SquareHolder Demo'),
        // ),
        body: Column(
          children: [
            //FIRST THING
            SizedBox(height: paddingHeight * 2),
            Transform.scale(
              scale: compensationScale,
              child: Transform.rotate(
                angle: -holderAngle,
                child: SquareHolder(
                  height: elementHeight / compensationScale,
                  padding: 10,
                  velocity: -0.1,
                ),
              ),
            ),
            //SECOND THING
            SizedBox(height: paddingHeight),
            Container(
              height: elementHeight,
              child: Text(
                'chroma\nguesser',
                style: GoogleFonts.abrilFatface(
                  textStyle: TextStyle(
                    fontSize: elementHeight * 0.9 / 2,
                    height: 1,
                  ),
                ),
              ),
            ),
            // Transform.scale(
            //   scale: compensationScale,
            //   child: Transform.rotate(
            //     angle: holderAngle,
            //     child: SquareHolder(
            //       height: elementHeight / compensationScale,
            //       padding: 10,
            //       velocity: 0.1,
            //     ),
            //   ),
            // ),
            //THIRD THING
            SizedBox(height: paddingHeight),
            Transform.scale(
              scale: compensationScale,
              child: Transform.rotate(
                angle: -holderAngle,
                child: SquareHolder(
                  height: elementHeight / compensationScale,
                  padding: 10,
                  velocity: -0.1,
                ),
              ),
            ),
            //FOURTH THING
            SizedBox(height: paddingHeight),
            Transform.scale(
              scale: compensationScale,
              child: Transform.rotate(
                angle: holderAngle,
                child: SquareHolder(
                  height: elementHeight / compensationScale,
                  padding: 10,
                  velocity: 0.1,
                ),
              ),
            ),
            //FIFTH THING
            SizedBox(height: paddingHeight),
            Transform.scale(
              scale: compensationScale,
              child: Transform.rotate(
                angle: -holderAngle,
                child: SquareHolder(
                  height: elementHeight / compensationScale,
                  padding: 10,
                  velocity: -0.1,
                ),
              ),
            ),
            SizedBox(height: paddingHeight),
          ],
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
  List<AnimatedSquare> _squares = <AnimatedSquare>[];
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
    numSquares = (screenWidth / _squareWidthWithPadding).ceil() + 1 + 1; //1 for safety, second 1 should be modified to add extra colors if wanted

    if (widget.velocity > 0) {
      for (var i = numSquares - 1; i >= 0; i--) {
        _squares.add(
          AnimatedSquare(
            size: _squareSize,
            padding: widget.padding,
            position: i * _squareWidthWithPadding,
            color: Color.fromARGB(
              255,
              _random.nextInt(256),
              _random.nextInt(256),
              _random.nextInt(256),
            ),
            label: i + 1,
          ),
        );
      }
    } else {
      for (var i = 0; i < numSquares; i++) {
        _squares.add(
          AnimatedSquare(
            size: _squareSize,
            padding: widget.padding,
            position: i * _squareWidthWithPadding,
            color: Color.fromARGB(
              255,
              //not 0 to 255, want to make it a bit more muted
              _random.nextInt(200) + 28,
              _random.nextInt(200) + 28,
              _random.nextInt(200) + 28,
            ),
            label: i + 1,
          ),
        );
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
      color: Colors.white,
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
          child: Center(
            child: Text(
              color.colorName,
              textAlign: TextAlign.center,
              style: GoogleFonts.abrilFatface(textStyle: TextStyle(color: getContrastingColor(color), fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }
}

Color getContrastingColor(Color color) {
  HSLColor hslColor = HSLColor.fromColor(color);

  // Adjust lightness
  double adjustedLightness = hslColor.lightness > 0.5 ? hslColor.lightness - 0.4 : hslColor.lightness + 0.4;

  // Ensure lightness is within a reasonable range
  adjustedLightness = adjustedLightness.clamp(0.2, 0.8);

  // Adjust saturation
  double adjustedSaturation = hslColor.lightness > 0.5 ? (hslColor.saturation * 0.6).clamp(0.0, 1.0) : (hslColor.saturation * 1.4).clamp(0.0, 1.0);

  // Maintain perceptual brightness by tweaking saturation
  if (hslColor.hue >= 60 && hslColor.hue <= 180) {
    // Greenish colors
    adjustedLightness = hslColor.lightness > 0.5 ? hslColor.lightness - 0.35 : hslColor.lightness + 0.35;
  } else if (hslColor.hue > 180 && hslColor.hue < 300) {
    // Blueish colors
    adjustedLightness = hslColor.lightness > 0.5 ? hslColor.lightness - 0.45 : hslColor.lightness + 0.45;
  }

  // Ensure lightness is within a reasonable range after perceptual tweaks
  adjustedLightness = adjustedLightness.clamp(0.2, 0.8);

  return hslColor.withLightness(adjustedLightness).withSaturation(adjustedSaturation).toColor();
}
