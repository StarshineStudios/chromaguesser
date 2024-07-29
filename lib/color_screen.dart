import 'dart:math';
import 'package:colorguesser/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:colornames/colornames.dart';

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
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
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
}
