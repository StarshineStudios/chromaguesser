import 'dart:async';
import 'dart:math' as math;
import 'dart:math';
import 'package:colorguesser/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:colornames/colornames.dart';

// MAIN
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        backgroundColor: backgroundColor,
        // appBar: AppBar(
        //   title: Text('SquareHolder Demo'),
        // ),
        body: ListView(
          children: [
            //FIRST THING
            // SizedBox(height: paddingHeight * 2),
            Transform.scale(
              scale: compensationScale,
              child: Transform.rotate(
                angle: holderAngle,
                child: SquareHolder(
                  biasColor: const Color.fromARGB(255, 200, 0, 0),
                  height: elementHeight / compensationScale,
                  padding: 10,
                  velocity: 0.1,
                ),
              ),
            ),
            //SECOND THING
            SizedBox(height: paddingHeight * 0.3),
            Center(
              child: Text(
                textAlign: TextAlign.center,
                'chroma\nguesser',
                style: GoogleFonts.abrilFatface(
                  textStyle: TextStyle(
                    color: lightColor,
                    fontSize: elementHeight * 1.4 / 2,
                    height: 1,
                  ),
                ),
              ),
            ),
            SizedBox(height: paddingHeight * 0.6),

            Center(
              child: Text(
                textAlign: TextAlign.center,
                'Press any color to start!',
                style: GoogleFonts.abrilFatface(
                  textStyle: TextStyle(
                    color: lightColor,
                    fontSize: elementHeight * 0.4 / 2,
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
                  biasColor: const Color.fromARGB(255, 184, 141, 0),
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
                  biasColor: const Color.fromARGB(255, 18, 193, 100),
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
                  biasColor: const Color.fromARGB(255, 10, 10, 134),
                  height: elementHeight / compensationScale,
                  padding: 10,
                  velocity: -0.1,
                ),
              ),
            ),
            //FIFTH THING
            SizedBox(height: paddingHeight),
            Transform.scale(
              scale: compensationScale,
              child: Transform.rotate(
                angle: holderAngle,
                child: SquareHolder(
                  biasColor: const Color.fromARGB(255, 164, 164, 164),
                  height: elementHeight / compensationScale,
                  padding: 10,
                  velocity: 0.1,
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

    if (widget.velocity > 0) {
      for (var i = numSquares - 1; i >= 0; i--) {
        _squares.add(
          AnimatedSquare(
            size: _squareSize,
            padding: widget.padding,
            position: i * _squareWidthWithPadding,
            color: getRandomColor(widget.biasColor, distance: 150),
            label: i + 1,
          ),
        );
        for (int j = 0; j < _squares.length - 1; j++) {
          if (_squares[j].color.colorName == _squares[_squares.length - 1].color.colorName) {
            i++;
            print('repeat deleted');
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
            color: getRandomColor(widget.biasColor, distance: 150),
            label: i + 1,
          ),
        );
        for (int j = 0; j < _squares.length - 1; j++) {
          if (_squares[j].color == _squares[_squares.length - 1].color) {
            i--;
            print('repeat deleted');
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
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                color.colorName.replaceAll(RegExp(' '), '\n'),
                textAlign: TextAlign.center,
                style: GoogleFonts.abrilFatface(textStyle: TextStyle(color: getContrastingColor(color), fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Color getContrastingColor(Color color) {
  HSLColor hslColor = HSLColor.fromColor(color);

  // Adjust lightness, prefer to brighten
  double adjustedLightness = hslColor.lightness > 0.75 ? hslColor.lightness - 0.4 : hslColor.lightness + 0.4;

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

Color getRandomColor(Color inputColor, {int distance = 50}) {
  final Random random = Random();

  // Helper function to clamp values between 0 and 255
  int clamp(int value) {
    return value.clamp(0, 255).toInt();
  }

  // Generate random changes for each RGB component
  List<int> getRandomChanges(int distance) {
    List<int> changes = [0, 0, 0];
    int remainingDistance = distance;

    // Distribute the distance randomly among R, G, B
    for (int i = 0; i < 3; i++) {
      int maxChange = min(remainingDistance, 255);
      int change = random.nextInt(maxChange + 1); // Change can be from 0 to remainingDistance
      changes[i] = random.nextBool() ? change : -change;
      remainingDistance -= change.abs();
    }

    // Ensure the sum of absolute changes is less than or equal to the specified distance
    while (remainingDistance > 0) {
      int i = random.nextInt(3);
      int maxChange = min(remainingDistance, 255 - changes[i].abs());
      int change = random.nextInt(maxChange + 1);
      changes[i] += random.nextBool() ? change : -change;
      remainingDistance -= change.abs();
    }

    return changes;
  }

  // Get the changes for RGB values
  List<int> rgbChanges = getRandomChanges(distance);

  int red = clamp(inputColor.red + rgbChanges[0]);
  int green = clamp(inputColor.green + rgbChanges[1]);
  int blue = clamp(inputColor.blue + rgbChanges[2]);

  return Color.fromARGB(inputColor.alpha, red, green, blue);
}
