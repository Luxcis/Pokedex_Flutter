import 'package:flutter/material.dart';
import 'package:pokedex/utils/pokemon_type_colors.dart';

class TypeChip extends StatelessWidget {
  final String type;
  final bool large;

  const TypeChip({super.key, required this.type, this.large = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 8,
        vertical: large ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: PokemonTypeColors.getTypeColor(type),
        borderRadius: BorderRadius.circular(large ? 16 : 12),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: Colors.white,
          fontSize: large ? 16 : 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class TypeChipSmall extends StatelessWidget {
  final String type;

  const TypeChipSmall({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: PokemonTypeColors.getTypeColor(type),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }
}
