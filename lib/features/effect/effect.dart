import 'package:flutter/material.dart';
import 'package:pokedex/features/settings/settings.dart';

class EffectPage extends StatefulWidget {
  const EffectPage({super.key});

  @override
  State createState() => _EffectPageState();
}

class _EffectPageState extends State<EffectPage> {
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
