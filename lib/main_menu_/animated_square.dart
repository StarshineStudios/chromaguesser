import 'package:colorguesser/color_screen.dart';
import 'package:colorguesser/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:colornames/colornames.dart';

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
