import 'package:flutter/material.dart';
import 'dart:math';

import 'package:google_fonts/google_fonts.dart';

const Color backgroundColor = Color.fromARGB(255, 31, 29, 50);

const Color foregroundColor = Color.fromARGB(255, 68, 64, 103);

const Color brightColor = Color.fromARGB(255, 87, 76, 190);

const Color fadedColor = Color.fromARGB(255, 103, 102, 121);
const Color lightColor = Color.fromARGB(255, 255, 255, 255);

TextStyle niceTextStyle(double fontSize) {
  return GoogleFonts.abrilFatface(
      textStyle: TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.normal,
    fontSize: fontSize,
  ));
}

class NiceButton extends StatefulWidget {
  final Color color;
  final Color inactiveColor;
  final double borderRadius;
  final double height;
  final Widget child;
  final VoidCallback onPressed;
  final bool active;
  const NiceButton({
    super.key,
    this.color = foregroundColor,
    this.inactiveColor = fadedColor,
    this.borderRadius = 8.0,
    this.height = 6,
    this.active = true,
    required this.child,
    required this.onPressed,
  });

  @override
  State<NiceButton> createState() => _NiceButtonState();
}

//https://stackoverflow.com/a/67989242
extension ColorBrightness on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}

class _NiceButtonState extends State<NiceButton> {
  double _paddingTop = 0;
  late double _paddingBottom = widget.height;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() {
        _paddingTop = widget.height;
        _paddingBottom = 0;
      }),
      onTapUp: (_) => setState(() {
        _paddingTop = 0;
        _paddingBottom = widget.height;

        if (widget.active) {
          widget.onPressed();
        }
      }),
      child: AnimatedContainer(
        padding: EdgeInsets.only(top: _paddingTop),
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          color: const Color.fromARGB(0, 0, 0, 0), //transparent
          borderRadius: BorderRadius.circular(10),
        ),
        child: AnimatedContainer(
          padding: EdgeInsets.only(bottom: _paddingBottom),
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            color: widget.active ? widget.color.darken() : widget.inactiveColor.darken(),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              color: widget.active ? widget.color : widget.inactiveColor,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

extension ColorNameRGB on Color {
  String get colorNameRGB {
    return 'R: $red, G: $green, B: $blue';
  }
}

Color getContrastingColor(Color color, {int alpha = 255}) {
  if (color == Colors.black || color == Colors.white) return Colors.grey;

  double threshold = 0.5;
  HSLColor hslColor = HSLColor.fromColor(color);

  // We use a formula for the perceived brightness. Green > red > blue in brightness.
  // The max perceived brightness is obviously
  double greenFactor = 0.587, redFactor = 0.299, blueFactor = 0.114;
  double percievedBrightness =
      (color.green * greenFactor + color.red * redFactor + color.blue * blueFactor) / (255 * greenFactor + 255 * redFactor + 255 * blueFactor);

  // Adjust lightness, prefer to darken
  double adjustedLightness = percievedBrightness > threshold ? hslColor.lightness - 0.6 : hslColor.lightness + 0.6;

  // Ensure lightness is within a reasonable range
  adjustedLightness = adjustedLightness.clamp(0.2, 0.8);

  // Adjust saturation
  double adjustedSaturation = percievedBrightness > threshold ? (hslColor.saturation * 0.6).clamp(0.0, 1.0) : (hslColor.saturation * 1.4).clamp(0.0, 1.0);

  // Return the color with the adjusted lightness, saturation, and the alpha channel set
  return hslColor.withLightness(adjustedLightness).withSaturation(adjustedSaturation).toColor().withAlpha(alpha);
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
