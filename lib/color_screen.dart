import 'dart:math';
import 'package:colorguesser/constants.dart';
import 'package:colorguesser/main_menu_/animated_square.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        redSliderValue = 128,
        greenSliderValue = 128,
        blueSliderValue = 128;

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
      redSliderValue = 128;
      greenSliderValue = 128;
      blueSliderValue = 128;
      hasSubmitted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Color Game'),
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
                    const Icon(Icons.favorite, color: Colors.red),
                    const SizedBox(width: 5),
                    Text(
                      'Health: $health',
                      style: niceTextStyle(20),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text('Score: $score'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            NormalSquare(size: 200, padding: 1, color: currentColor).getWidget(context),
            const SizedBox(height: 20),
            // if (!hasSubmitted)
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
                    // if (hasSubmitted)
                    //   Positioned(
                    //     bottom: 40,
                    //     child: Text(
                    //       //TODO: DO THIS
                    //       'Difference: DO THIS${Color.fromARGB(255, redSliderValue.floor(), greenSliderValue.floor(), blueSliderValue.floor()).colorName}',
                    //       style: niceTextStyle(20),
                    //     ),
                    //   )
                  ],
                ),
              ),
            ),
            // if (hasSubmitted)
            //   Column(
            //     children: [
            //       const Text(
            //         'Your Guess',
            //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            //       ),
            //       const SizedBox(height: 10),
            //       Container(
            //         width: 100,
            //         height: 100,
            //         color: guessedColor,
            //       ),
            //       if (health <= 0)
            //         const Padding(
            //           padding: EdgeInsets.only(top: 20.0),
            //           child: Text(
            //             'Thanks for playing',
            //             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            //           ),
            //         ),
            //     ],
            //   ),
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
              size: Size(111, 111),
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
            infoProperties: InfoProperties(mainLabelStyle: TextStyle(fontSize: 0)),
            customColors: CustomSliderColors(
              dotColor: Color.fromARGB(alpha, 0, 0, 0),
              shadowMaxOpacity: 0,
              trackColor: Colors.transparent,
              progressBarColor: getContrastingColor(color, alpha: alpha),
            ),
          ),
          onChange: onChanged,
        ),
        Text(
          value.round().toString(),
          style: TextStyle(fontSize: 30, color: getContrastingColor(color, alpha: alpha)),
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
