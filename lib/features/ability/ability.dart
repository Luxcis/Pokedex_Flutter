import 'package:flutter/material.dart';
import 'package:pokedex/features/settings/settings.dart';

class AbilityPage extends StatefulWidget {
  const AbilityPage({super.key});

  @override
  State createState() => _AbilityPageState();
}

class _AbilityPageState extends State<AbilityPage> {
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
