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
          child: ElevatedButton(
            onPressed: () {
              // Show the confirmation dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Delete Saved highscore?'),
                    content: const Text('This cannot be reversed?'),
                    actions: <Widget>[
                      ElevatedButton(
                        child: const Text('Yes'),
                        onPressed: () {
                          // Perform the delete action here
                          // For now, just close the dialog
                          box.delete('highscore');
                          Navigator.of(context).pop();
                        },
                      ),
                      ElevatedButton(
                        child: const Text('No'),
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
            child: const Text('Delete Progress'),
          ),
        );
      },
    );
  }
}
