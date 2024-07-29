import 'package:flutter/material.dart';


import 'constants.dart';
import 'dart:math' as math;
import 'package:colorguesser/main_menu_elements.dart';
import 'package:google_fonts/google_fonts.dart';

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
                  biasColor: const Color.fromARGB(255, 184, 104, 0),
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

////////////////////////////////////////////////////////////////////////OLD STUFF
const generalBox = 'generalBoxString';

// //MAIN
// void main() async {
//   await Hive.initFlutter();
//   await Hive.openBox(generalBox);
//   runApp(const ColorGuesserApp());
// }

// //THE APP
// class ColorGuesserApp extends StatelessWidget {
//   const ColorGuesserApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: ColorGuesserScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// //TODO: FIX THIS
// List<Widget> pages = [
//   const GameScreen(),
//   const SettingsScreen(),
// ];

// //The main screen
// class ColorGuesserScreen extends StatefulWidget {
//   const ColorGuesserScreen({super.key});

//   @override
//   State<ColorGuesserScreen> createState() => _ColorGuesserScreenState();
// }

// class _ColorGuesserScreenState extends State<ColorGuesserScreen> {
//   int navBarIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: pages[navBarIndex],
//       bottomNavigationBar: Container(
//         height: 75,
//         color: foregroundColor,
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: GNav(
//             activeColor: lightColor,
//             tabBackgroundColor: backgroundColor,

//             //the icon color btw
//             color: lightColor,
//             textStyle: const TextStyle(
//               color: lightColor,
//             ),
//             padding: const EdgeInsets.all(13),
//             gap: 8,
//             iconSize: 30,
//             onTabChange: (index) {
//               setState(() {
//                 navBarIndex = index;
//               });
//             },
//             tabs: const [
//               GButton(
//                 icon: Icons.square,
//                 text: 'Game',
//               ),
//               GButton(
//                 icon: Icons.settings,
//                 text: 'Settings',
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
