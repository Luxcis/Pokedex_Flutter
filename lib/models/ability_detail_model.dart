class AbilityDetailModel {
  final String index;
  final String name;
  final String nameJp;
  final String nameEn;
  final String generation;
  final String text;
  final String effect;
  final List<String> info;
  final int commonCount;
  final int hiddenCount;
  final List<AbilityPokemon> pokemon;

  const AbilityDetailModel({
    required this.index,
    required this.name,
    required this.nameJp,
    required this.nameEn,
    required this.generation,
    required this.text,
    required this.effect,
    required this.info,
    required this.commonCount,
    required this.hiddenCount,
    required this.pokemon,
  });

  factory AbilityDetailModel.fromJson(Map<String, dynamic> json) {
    return AbilityDetailModel(
      index: json['index'] ?? '',
      name: json['name'] ?? '',
      nameJp: json['name_jp'] ?? '',
      nameEn: json['name_en'] ?? '',
      generation: json['generation'] ?? '',
      text: json['text'] ?? '',
      effect: json['effect'] ?? '',
      info: List<String>.from(json['info'] ?? []),
      commonCount: json['common_count'] ?? 0,
      hiddenCount: json['hidden_count'] ?? 0,
      pokemon:
          (json['pokemon'] as List<dynamic>?)
              ?.map((p) => AbilityPokemon.fromJson(p))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'name': name,
      'name_jp': nameJp,
      'name_en': nameEn,
      'generation': generation,
      'text': text,
      'effect': effect,
      'info': info,
      'common_count': commonCount,
      'hidden_count': hiddenCount,
      'pokemon': pokemon.map((p) => p.toJson()).toList(),
    };
  }
}

class AbilityPokemon {
  final String index;
  final String name;
  final List<String> types;
  final String firstAbility;
  final String secondAbility;
  final String hiddenAbility;

  const AbilityPokemon({
    required this.index,
    required this.name,
    required this.types,
    required this.firstAbility,
    required this.secondAbility,
    required this.hiddenAbility,
  });

  factory AbilityPokemon.fromJson(Map<String, dynamic> json) {
    return AbilityPokemon(
      index: json['index'] ?? '',
      name: json['name'] ?? '',
      types: List<String>.from(json['types'] ?? []),
      firstAbility: json['first'] ?? '',
      secondAbility: json['second'] ?? '',
      hiddenAbility: json['hidden'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'name': name,
      'types': types,
      'first': firstAbility,
      'second': secondAbility,
      'hidden': hiddenAbility,
    };
  }
}
