import 'package:colorguesser/constants.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box(generalBox).listenable(),
      builder: (context, box, widget) {
        return Center(
          child: NiceButton(
            onPressed: () {
              // Show the confirmation dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: backgroundColor,
                    title: const Text(
                      'Delete Saved highscore?',
                      style: TextStyle(color: lightColor),
                    ),
                    content: const Text(
                      'This cannot be reversed?',
                      style: TextStyle(color: lightColor),
                    ),
                    actions: <Widget>[
                      NiceButton(
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Yes',
                            style: TextStyle(color: lightColor),
                          ),
                        ),
                        onPressed: () {
                          // Perform the delete action here
                          // For now, just close the dialog
                          box.delete('highscore');
                          box.delete('highscoreNew');
                          Navigator.of(context).pop();
                        },
                      ),
                      NiceButton(
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'No',
                            style: TextStyle(color: lightColor),
                          ),
                        ),
                        onPressed: () {
                          // Close the dialog
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Delete Progress',
                style: TextStyle(color: lightColor),
              ),
            ),
          ),
        );
      },
    );
  }
}
