import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'main.dart';

import 'dart:math';
import 'constants.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class NewColor {
  int red;
  int green;
  int blue;
  NewColor(this.red, this.green, this.blue);
}

class _GameScreenState extends State<GameScreen> {
  bool gameStarted = false;
  final int maxHealth = 765;
  //bool elementsVisible = true;
  //bool newElementsVisible = false;
  //bool slidersVisible = false;
  late Color squareColor; // Mark as late and initialize it in initState

  late int health = maxHealth;

  double redSliderValue = 128;
  double greenSliderValue = 128;
  double blueSliderValue = 128;

  List<Color> squareColors = [];
  List<Color> guessedColors = [];

  int score = 0;

  Color mixColors(Color color1, Color color2, double factor) {
    //factor is opacity of color2
    factor = factor.clamp(0.0, 1.0); // Ensure the factor is between 0 and 1

    int r = (color1.red * (1 - factor) + color2.red * factor).toInt();
    int g = (color1.green * (1 - factor) + color2.green * factor).toInt();
    int b = (color1.blue * (1 - factor) + color2.blue * factor).toInt();
    int a = (color1.alpha * (1 - factor) + color2.alpha * factor).toInt();

    return Color.fromARGB(a, r, g, b);
  }

  Color visibleColor(Color backgroundColor) {
    int red = backgroundColor.red;
    int green = backgroundColor.green;
    int blue = backgroundColor.blue;
    int total = red + green + blue;
    //middle expected
    if (total > 383) {
      return mixColors(backgroundColor, Colors.black, 0.8);
    }
    return mixColors(backgroundColor, Colors.white, 0.8);
  }

  Color randomColor() {
    final Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  void _startGame() {
    setState(() {
      gameStarted = true;
    });
  }

  String colorToString(Color color) {
    return '(${color.red}, ${color.green}, ${color.blue})';
  }

  String newColorToString(NewColor color) {
    return '(${color.red > 0 ? '+' : ''}${color.red}, ${color.green > 0 ? '+' : ''}${color.green}, ${color.blue > 0 ? '+' : ''}${color.blue})';
  }

  NewColor colorDifference(Color color1, Color color2) {
    int redDifference = (color2.red - color1.red);
    int greenDifference = (color2.green - color1.green);
    int blueDifference = (color2.blue - color1.blue);

    return NewColor(redDifference, greenDifference, blueDifference);
  }

  Color absColorDifference(Color color1, Color color2) {
    int redDifference = (color1.red - color2.red).abs();
    int greenDifference = (color1.green - color2.green).abs();
    int blueDifference = (color1.blue - color2.blue).abs();

    return Color.fromRGBO(redDifference, greenDifference, blueDifference, 1);
  }

  int totalDifference(Color color) {
    return color.red + color.green + color.blue;
  }

  @override
  void initState() {
    super.initState();
    squareColor = randomColor(); // Initialize the square color
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box(generalBox).listenable(),
      builder: (context, box, widget) {
        int highscore = box.get('highscore', defaultValue: -1);
        bool highscoreNew = box.get('highscoreNew', defaultValue: false);
        String highscoreText = highscore == -1
            ? ''
            : '${highscoreNew ? 'New ' : ''}Highscore${highscoreNew ? '!' : ':'} $highscore';

        void check() {
          setState(() {
            //Change score and health
            score++;
            Color guessedColor = Color.fromRGBO(redSliderValue.toInt(),
                greenSliderValue.toInt(), blueSliderValue.toInt(), 1);
            health -=
                totalDifference(absColorDifference(guessedColor, squareColor));

            //save the colors

            squareColors.add(squareColor);
            guessedColors.add(guessedColor);

            //reset the colors
            redSliderValue = 128;
            greenSliderValue = 128;
            blueSliderValue = 128;
            squareColor = randomColor();

            //see if game should end
            if (health <= 0) {
              gameStarted = false;

              if (score > highscore) {
                box.put('highscore', score);
                box.put('highscoreNew', true);
              } else {
                box.put('highscoreNew', false);
              }

              health = maxHealth;
              score = 0;
              squareColors = [];
              guessedColors = [];
            }
          });
        }

        bool previousReady = score >= 1;
        return GestureDetector(
          onTap: () {
            if (!gameStarted) {
              _startGame();
            }
          },
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                top: !gameStarted
                    ? 75
                    : -MediaQuery.of(context).size.height * 0.1,
                left: 0,
                right: 0,
                child: const Center(
                  child: Text(
                    'ChromaGuesser',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                bottom: !gameStarted
                    ? 75
                    : -MediaQuery.of(context).size.height * 0.1,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Tap Square to Guess!\n$highscoreText',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                top:
                    gameStarted ? 0 : -MediaQuery.of(context).size.height * 0.1,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 30, right: 30, top: 10, bottom: 10),
                    decoration: const BoxDecoration(
                      color: foregroundColor, // Medium grey color

                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10)),
                    ),
                    child: Text(
                      'Score: $score \nHealth: $health',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                bottom:
                    gameStarted ? 0 : -MediaQuery.of(context).size.height * 1,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    if (previousReady)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        padding: const EdgeInsets.all(16),
                        child: Opacity(
                          opacity: score >= 1 ? 1 : 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width *
                                            0.25 <
                                        180
                                    ? MediaQuery.of(context).size.width * 0.25
                                    : 180,
                                height: MediaQuery.of(context).size.width *
                                            0.25 <
                                        180
                                    ? MediaQuery.of(context).size.width * 0.25
                                    : 180,
                                color: squareColors[score - 1],
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Previous Color:\n${colorToString(squareColors[score - 1])}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: visibleColor(
                                            squareColors[score - 1])),
                                  ),
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width *
                                            0.25 <
                                        180
                                    ? MediaQuery.of(context).size.width * 0.25
                                    : 180,
                                height: MediaQuery.of(context).size.width *
                                            0.25 <
                                        180
                                    ? MediaQuery.of(context).size.width * 0.25
                                    : 180,
                                color: guessedColors[score - 1],
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Previous Guess:\n${colorToString(guessedColors[score - 1])}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: visibleColor(
                                            guessedColors[score - 1])),
                                  ),
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width *
                                            0.25 <
                                        180
                                    ? MediaQuery.of(context).size.width * 0.25
                                    : 180,
                                height: MediaQuery.of(context).size.width *
                                            0.25 <
                                        180
                                    ? MediaQuery.of(context).size.width * 0.25
                                    : 180,
                                color: absColorDifference(
                                    squareColors[score - 1],
                                    guessedColors[score - 1]),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Difference:\n(Darker the Better)\n${newColorToString(colorDifference(squareColors[score - 1], guessedColors[score - 1]))}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: visibleColor(absColorDifference(
                                            squareColors[score - 1],
                                            guessedColors[score - 1]))),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: foregroundColor, // Medium grey color

                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Slider(
                            value: redSliderValue,
                            onChanged: (value) {
                              setState(() {
                                redSliderValue = value;
                              });
                            },
                            activeColor: Colors.red, // Red slider
                            min: 0,
                            max: 255,
                          ),
                          Slider(
                            value: greenSliderValue,
                            onChanged: (value) {
                              setState(() {
                                greenSliderValue = value;
                              });
                            },
                            activeColor: Colors.green, // Green slider
                            min: 0,
                            max: 255,
                          ),
                          Slider(
                            value: blueSliderValue,
                            onChanged: (value) {
                              setState(() {
                                blueSliderValue = value;
                              });
                            },
                            activeColor: Colors.blue, // Blue slider
                            min: 0,
                            max: 255,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                '(${redSliderValue.toInt()}, ${greenSliderValue.toInt()}, ${blueSliderValue.toInt()})',
                                style: const TextStyle(
                                  color: lightColor,
                                  fontSize: 20,
                                ),
                              ),
                              NiceButton(
                                onPressed: check,
                                color: brightColor,
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Check',
                                    style: TextStyle(color: lightColor),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                top: gameStarted ? 90 : 140,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: MediaQuery.of(context).size.width * 0.8 < 275
                        ? MediaQuery.of(context).size.width * 0.8
                        : 275,
                    height: MediaQuery.of(context).size.width * 0.8 < 275
                        ? MediaQuery.of(context).size.width * 0.8
                        : 275,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      border: Border.all(color: Colors.white, width: 2.0),
                      color: squareColor,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Guess this Color!',
                      style: TextStyle(
                          color: visibleColor(squareColor), fontSize: 40),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
