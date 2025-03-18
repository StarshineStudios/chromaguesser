import 'dart:math';
import 'package:colorguesser/constants.dart';
import 'package:colorguesser/main_menu_/animated_square.dart';
import 'package:flutter/material.dart';
import 'package:colornames/colornames.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class ColorSelectionScreen extends StatefulWidget {
  final Color initialColor;

  const ColorSelectionScreen({super.key, required this.initialColor});

  @override
  State<ColorSelectionScreen> createState() => _ColorSelectionScreenState();
}

class _ColorSelectionScreenState extends State<ColorSelectionScreen> {
  int health = 765;
  double accuracy = 1.0; //percent
  int score = 0;
  bool hasSubmitted = false;
  Color currentColor;
  Color guessedColor;
  double redSliderValue;
  double greenSliderValue;
  double blueSliderValue;

  _ColorSelectionScreenState()
      : currentColor = Colors.white,
        guessedColor = Colors.white,
        redSliderValue = 255,
        greenSliderValue = 255,
        blueSliderValue = 255;

  @override
  void initState() {
    super.initState();
    currentColor = widget.initialColor;
  }

  String get colorNameRGB => currentColor.toString().split('(0x')[1].split(')')[0];

  void updateColor() {
    setState(() {
      score++;
      guessedColor = Color.fromRGBO(redSliderValue.toInt(), greenSliderValue.toInt(), blueSliderValue.toInt(), 1.0);
      int redDiff = (currentColor.red - guessedColor.red).abs();
      int greenDiff = (currentColor.green - guessedColor.green).abs();
      int blueDiff = (currentColor.blue - guessedColor.blue).abs();
      int totalDiff = redDiff + greenDiff + blueDiff;
      health -= totalDiff;

      accuracy = (((765 - totalDiff) / 765) + accuracy * score) / ((score + 1));

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
      redSliderValue = 255;
      greenSliderValue = 255;
      blueSliderValue = 255;
      hasSubmitted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: lightColor,
        title: Text(
          'ChromaGuesser',
          style: niceTextStyle(30),
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                )),
            child: Column(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 40,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Health: $health',
                          style: niceTextStyle(30),
                        ),
                      ],
                    ),
                    const SizedBox(width: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.transit_enterexit_sharp,
                          color: Colors.blue,
                          size: 40,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Accuracy: ${(accuracy * 100).toStringAsFixed(2)}%',
                          style: niceTextStyle(30),
                        ),
                      ],
                    ),
                    const SizedBox(width: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.yellow,
                          size: 40,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Score: $score',
                          style: niceTextStyle(30),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                NormalSquare(size: 200, padding: 1, color: currentColor).getWidget(context),
                const SizedBox(height: 20),
                // if (!hasSubmitted)
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black,
              ),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  //THE ACTUAL LIGHTS
                  AnimatedPositioned(
                    duration: const Duration(seconds: 1),
                    right: hasSubmitted ? 0 : MediaQuery.of(context).size.width - 200,
                    left: 0,
                    top: hasSubmitted ? 60 : 30,
                    child: buildSlider(
                      'Red',
                      redSliderValue,
                      Color.fromARGB(255, redSliderValue.round(), 0, 0),
                      (value) {
                        setState(() {
                          redSliderValue = value;
                        });
                      },
                      hasSubmitted ? 0 : 255,
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(seconds: 1),
                    left: hasSubmitted ? 0 : MediaQuery.of(context).size.width - 200,
                    right: 0,
                    top: hasSubmitted ? 60 : 30,
                    child: buildSlider(
                      'Green',
                      greenSliderValue,
                      Color.fromARGB(255, 0, greenSliderValue.round(), 0),
                      (value) {
                        setState(() {
                          greenSliderValue = value;
                        });
                      },
                      hasSubmitted ? 0 : 255,
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(seconds: 1),
                    top: hasSubmitted ? 60 : 160,
                    child: buildSlider(
                      'Blue',
                      blueSliderValue,
                      Color.fromARGB(255, 0, 0, blueSliderValue.round()),
                      (value) {
                        setState(() {
                          blueSliderValue = value;
                        });
                      },
                      hasSubmitted ? 0 : 255,
                    ),
                  ),
                  if (hasSubmitted)
                    Positioned(
                      bottom: 40,
                      child: Text(
                        'Your Guess: ${Color.fromARGB(255, redSliderValue.floor(), greenSliderValue.floor(), blueSliderValue.floor()).colorName}',
                        style: niceTextStyle(20),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
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
    );
  }

  Widget buildSlider(String label, double value, Color color, ValueChanged<double> onChanged, int alpha) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 0,
            height: 0,
            child: CustomPaint(
              size: const Size(111, 111),
              painter: BlendingCirclesPainter(color),
            ),
          ),
        ),
        SleekCircularSlider(
          initialValue: value,
          min: 0,
          max: 255,
          appearance: CircularSliderAppearance(
            customWidths: CustomSliderWidths(
              trackWidth: 0,
              progressBarWidth: 10,
            ),
            startAngle: 90 + 30,
            angleRange: 300,
            infoProperties: InfoProperties(mainLabelStyle: const TextStyle(fontSize: 0)),
            customColors: CustomSliderColors(
              dotColor: Color.fromARGB(alpha, 0, 0, 0),
              shadowMaxOpacity: 0,
              trackColor: Colors.transparent,
              progressBarColor: alpha != 0 ? getContrastingColor(color, alpha: alpha) : Colors.transparent,
            ),
          ),
          onChange: onChanged,
        ),
        Text(
          value.round().toString(),
          style: TextStyle(fontSize: 30, color: alpha != 0 ? getContrastingColor(color, alpha: alpha) : Colors.transparent),
        ),
      ],
    );
  }
}

class BlendingCirclesPainter extends CustomPainter {
  final Color color;
  BlendingCirclesPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..blendMode = BlendMode.plus;
    double baseRadius = 80;

    void drawCircle(Color color, Offset center) {
      paint.color = color;
      canvas.drawCircle(center, baseRadius, paint);
    }

    drawCircle(color, const Offset(0, 0));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
