import 'package:flutter/material.dart';
import 'package:pokedex/features/settings/settings.dart';

class FusionPage extends StatefulWidget {
  const FusionPage({super.key});

  @override
  State createState() => _FusionPageState();
}

class _FusionPageState extends State<FusionPage> {
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
