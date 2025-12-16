import 'package:flutter/material.dart';
import 'package:pokedex/features/ability/ability.dart';
import 'package:pokedex/features/effect/effect.dart';
import 'package:pokedex/features/fusion/fusion.dart';
import 'package:pokedex/features/move/move.dart';
import 'package:pokedex/features/pokemon/pokemon.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(PhosphorIconsFill.pawPrint),
            icon: Icon(PhosphorIconsBold.pawPrint),
            label: '图鉴',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.lightbulb),
            icon: Icon(Icons.lightbulb_outlined),
            label: '特性',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.front_hand),
            icon: Icon(Icons.front_hand_outlined),
            label: '招式',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.pentagon),
            icon: Icon(Icons.pentagon_outlined),
            label: '克制',
          ),
          NavigationDestination(
            selectedIcon: Icon(PhosphorIconsBold.dna),
            icon: Icon(PhosphorIconsFill.dna),
            label: '融合',
          ),
        ],
      ),
      body:
      <Widget>[
        PokemonPage(),
        AbilityPage(),
        MovePage(),
        EffectPage(),
        FusionPage(),
      ][currentPageIndex],
    );
  }
}
