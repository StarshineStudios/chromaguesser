import 'dart:async';
import 'dart:math';
import 'package:colorguesser/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
            _squares.removeLast();
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
            _squares.removeLast();
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

  Widget getWidget(BuildContext context) {
    return Positioned(
      top: padding,
      left: position,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ColorScreen(initialColor: color),
            ),
          );
        },
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                color.colorName.replaceAll(RegExp(' '), '\n'),
                textAlign: TextAlign.center,
                style: GoogleFonts.abrilFatface(
                  textStyle: TextStyle(
                    color: getContrastingColor(color),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ColorScreen extends StatefulWidget {
  final Color initialColor;

  ColorScreen({required this.initialColor});

  @override
  _ColorScreenState createState() => _ColorScreenState();
}

class _ColorScreenState extends State<ColorScreen> {
  int health = 765;
  int score = 0;
  bool hasSubmitted = false;
  Color currentColor;
  Color guessedColor;
  double redSliderValue;
  double greenSliderValue;
  double blueSliderValue;

  _ColorScreenState()
      : currentColor = Colors.white,
        guessedColor = Colors.white,
        redSliderValue = 0,
        greenSliderValue = 0,
        blueSliderValue = 0;

  @override
  void initState() {
    super.initState();
    currentColor = widget.initialColor;
  }

  String get colorNameRGB => currentColor.toString().split('(0x')[1].split(')')[0];

  void updateColor() {
    setState(() {
      guessedColor = Color.fromRGBO(redSliderValue.toInt(), greenSliderValue.toInt(), blueSliderValue.toInt(), 1.0);
      int redDiff = (currentColor.red - guessedColor.red).abs();
      int greenDiff = (currentColor.green - guessedColor.green).abs();
      int blueDiff = (currentColor.blue - guessedColor.blue).abs();
      int totalDiff = redDiff + greenDiff + blueDiff;
      health -= totalDiff;
      score++;
      hasSubmitted = true;
    });
  }

  void nextRound() {
    setState(() {
      currentColor = Color.fromRGBO(
        Random().nextInt(256),
        Random().nextInt(256),
        Random().nextInt(256),
        1.0,
      );
      redSliderValue = 0;
      greenSliderValue = 0;
      blueSliderValue = 0;
      hasSubmitted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Color Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.red),
                    SizedBox(width: 5),
                    Text('Health: $health'),
                  ],
                ),
                Row(
                  children: [
                    Text('Score: $score'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              width: 100,
              height: 100,
              color: currentColor,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    currentColor.colorName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.abrilFatface(
                      textStyle: TextStyle(
                        color: getContrastingColor(currentColor),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (!hasSubmitted)
              Column(
                children: [
                  buildSlider('Red', redSliderValue, (value) {
                    setState(() {
                      redSliderValue = value;
                    });
                  }),
                  buildSlider('Green', greenSliderValue, (value) {
                    setState(() {
                      greenSliderValue = value;
                    });
                  }),
                  buildSlider('Blue', blueSliderValue, (value) {
                    setState(() {
                      blueSliderValue = value;
                    });
                  }),
                ],
              ),
            if (hasSubmitted)
              Column(
                children: [
                  Text(
                    'Your Guess',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: 100,
                    height: 100,
                    color: guessedColor,
                  ),
                ],
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (health <= 0) {
                  Navigator.pop(context);
                } else if (hasSubmitted) {
                  nextRound();
                } else {
                  updateColor();
                }
              },
              child: Text(health <= 0 ? 'Game Over: Exit' : (hasSubmitted ? 'Continue' : 'Submit')),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSlider(String label, double value, ValueChanged<double> onChanged) {
    return Row(
      children: [
        Text('$label: ${value.toInt()}'),
        Expanded(
          child: Slider(
            value: value,
            min: 0,
            max: 255,
            divisions: 255,
            label: value.toInt().toString(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Color getContrastingColor(Color color) {
    int d = 0;

    double luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;

    if (luminance > 0.5)
      d = 0; // bright colors - black font
    else
      d = 255; // dark colors - white font

    return Color.fromARGB(color.alpha, d, d, d);
  }
}

extension ColorNameRGB on Color {
  String get colorNameRGB {
    return 'R: ${red}, G: ${green}, B: ${blue}';
  }
}

Color getContrastingColor(Color color) {
  double threshold = 0.5;
  HSLColor hslColor = HSLColor.fromColor(color);

  //we use a formula for the percieved brightness. Green>red>blue in brightness.
  //the max percieved brightness is obviously
  double greenFactor = 0.9, redFactor = 0.5, blueFactor = 0.4;
  double percievedBrightness =
      (color.green * greenFactor + color.red * redFactor + color.blue * blueFactor) / (255 * greenFactor + 255 * redFactor + 255 * blueFactor);

  //FOR SOME REASON, GREEN APPEARS SUPER BRIGHT. I WILL JUST AUTO-DARKEN ANY COLOR WITH GREEN AS BIGGEST COLOR
  if (color.green * greenFactor > color.red * redFactor && color.green > color.blue * 0.6) percievedBrightness = 1;

  // Adjust lightness, prefer to darken
  //double adjustedLightness = hslColor.lightness > 0.3 ? hslColor.lightness - 0.4 : hslColor.lightness + 0.4;
  double adjustedLightness = percievedBrightness > threshold ? hslColor.lightness - 0.6 : hslColor.lightness + 0.6;

  // Ensure lightness is within a reasonable range
  adjustedLightness = adjustedLightness.clamp(0.2, 0.8);

  // Adjust saturation
  double adjustedSaturation = percievedBrightness > threshold ? (hslColor.saturation * 0.6).clamp(0.0, 1.0) : (hslColor.saturation * 1.4).clamp(0.0, 1.0);

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
