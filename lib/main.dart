import 'package:colorguesser/settings_screen.dart';
import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';

import 'package:google_nav_bar/google_nav_bar.dart';
import 'game_screen.dart';
import 'constants.dart';

const generalBox = 'generalBoxString';
void main() async {
  await Hive.initFlutter();
  await Hive.openBox(generalBox);
  runApp(const ColorGuesserApp());
}

class ColorGuesserApp extends StatelessWidget {
  const ColorGuesserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ColorGuesserScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

List<Widget> pages = [
  const GameScreen(),
  const SettingsScreen(),
];

class ColorGuesserScreen extends StatefulWidget {
  const ColorGuesserScreen({super.key});

  @override
  State<ColorGuesserScreen> createState() => _ColorGuesserScreenState();
}

class _ColorGuesserScreenState extends State<ColorGuesserScreen> {
  int navBarIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: pages[navBarIndex],
      bottomNavigationBar: Container(
        height: 75,
        color: foregroundColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GNav(
            activeColor: lightColor,
            tabBackgroundColor: backgroundColor,

            //the icon color btw
            color: lightColor,
            textStyle: const TextStyle(
              color: lightColor,
            ),
            padding: const EdgeInsets.all(13),
            gap: 8,
            iconSize: 30,
            onTabChange: (index) {
              setState(() {
                navBarIndex = index;
              });
            },
            tabs: const [
              GButton(
                icon: Icons.square,
                text: 'Game',
              ),
              GButton(
                icon: Icons.settings,
                text: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
