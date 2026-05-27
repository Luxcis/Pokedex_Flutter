class FusionPokemonModel {
  final String index;
  final String name;
  final String nameJp;
  final String nameEn;
  final String generation;
  final List<String> types;
  final String iconPosition;
  final int hp;
  final int attack;
  final int defense;
  final int spAttack;
  final int spDefense;
  final int speed;

  const FusionPokemonModel({
    required this.index,
    required this.name,
    required this.nameJp,
    required this.nameEn,
    required this.generation,
    required this.types,
    required this.iconPosition,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.spAttack,
    required this.spDefense,
    required this.speed,
  });

  factory FusionPokemonModel.fromJson(Map<String, dynamic> json) {
    return FusionPokemonModel(
      index: json['index'] ?? '',
      name: json['name'] ?? '',
      nameJp: json['name_jp'] ?? '',
      nameEn: json['name_en'] ?? '',
      generation: json['generation'] ?? '',
      types: List<String>.from(json['types'] ?? []),
      iconPosition: json['icon_position'] ?? '',
      hp: json['hp'] ?? 0,
      attack: json['attack'] ?? 0,
      defense: json['defense'] ?? 0,
      spAttack: json['sp_attack'] ?? 0,
      spDefense: json['sp_defense'] ?? 0,
      speed: json['speed'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'name': name,
      'name_jp': nameJp,
      'name_en': nameEn,
      'generation': generation,
      'types': types,
      'icon_position': iconPosition,
      'hp': hp,
      'attack': attack,
      'defense': defense,
      'sp_attack': spAttack,
      'sp_defense': spDefense,
      'speed': speed,
    };
  }

  int get totalStats => hp + attack + defense + spAttack + spDefense + speed;
}

class FusionResult {
  final List<String> types;
  final int hp;
  final int attack;
  final int defense;
  final int spAttack;
  final int spDefense;
  final int speed;
  final FusionPokemonModel headPokemon;
  final FusionPokemonModel bodyPokemon;

  const FusionResult({
    required this.types,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.spAttack,
    required this.spDefense,
    required this.speed,
    required this.headPokemon,
    required this.bodyPokemon,
  });

  int get totalStats => hp + attack + defense + spAttack + spDefense + speed;
}
