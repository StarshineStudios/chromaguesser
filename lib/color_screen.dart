import 'dart:math';
import 'package:colorguesser/constants.dart';
import 'package:colorguesser/main_menu_/animated_square.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:colornames/colornames.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class ColorScreen extends StatefulWidget {
  final Color initialColor;

  const ColorScreen({super.key, required this.initialColor});

  @override
  State<ColorScreen> createState() => _ColorScreenState();
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
                      style: niceTextStyle(5),
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
            if (!hasSubmitted)
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildSlider('Red', redSliderValue, Color.fromARGB(255, redSliderValue.round(), 0, 0), (value) {
                        setState(() {
                          redSliderValue = value;
                        });
                      }),
                      buildSlider('Green', greenSliderValue, Color.fromARGB(255, 0, greenSliderValue.round(), 0), (value) {
                        setState(() {
                          greenSliderValue = value;
                        });
                      }),
                    ],
                  ),
                  buildSlider('Blue', blueSliderValue, Color.fromARGB(255, 0, 0, blueSliderValue.round()), (value) {
                    setState(() {
                      blueSliderValue = value;
                    });
                  }),
                ],
              ),
            if (hasSubmitted)
              Column(
                children: [
                  const Text(
                    'Your Guess',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 100,
                    height: 100,
                    color: guessedColor,
                  ),
                  if (health <= 0)
                    const Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Text(
                        'Thanks for playing',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
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
      ),
    );
  }

  Widget buildSlider(String label, double value, Color color, ValueChanged<double> onChanged) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SleekCircularSlider(
          initialValue: value,
          min: 0,
          max: 255,
          appearance: CircularSliderAppearance(
            customWidths: CustomSliderWidths(
              trackWidth: 20,
              progressBarWidth: 10,
            ),
            startAngle: 90,
            angleRange: 360,
            infoProperties: InfoProperties(mainLabelStyle: TextStyle(fontSize: 0)),
            customColors: CustomSliderColors(
              trackColor: Colors.black,
              progressBarColor: Colors.white,
            ),
          ),
          onChange: onChanged,
        ),
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
        Text(
          value.round().toString(),
          style: TextStyle(fontSize: 30, color: getContrastingColor(color)),
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
    double baseRadius = 50;

    void drawCircle(Color color, Offset center) {
      paint.color = color;
      canvas.drawCircle(center, baseRadius, paint);
    }

    drawCircle(color, const Offset(0, 0));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
