import 'package:flutter/material.dart';
import 'package:pokedex/features/settings/settings.dart';

class MovePage extends StatefulWidget {
  const MovePage({super.key});

  @override
  State createState() => _MovePageState();
}

class _MovePageState extends State<MovePage> {
  @override
  Widget build(BuildContext context) {
    final actions = [
      IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const SettingsPage()));
        },
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Template'), actions: actions),
    );
  }
}
