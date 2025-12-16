class PokemonModel {
  final String index;
  final String name;
  final String nameJp;
  final String nameEn;
  final String generation;
  final List<String> types;
  final PokemonMeta meta;

  PokemonModel({
    required this.index,
    required this.name,
    required this.nameJp,
    required this.nameEn,
    required this.generation,
    required this.types,
    required this.meta,
  });

  factory PokemonModel.fromJson(Map<String, dynamic> json) {
    return PokemonModel(
      index: json['index'] ?? '',
      name: json['name'] ?? '',
      nameJp: json['name_jp'] ?? '',
      nameEn: json['name_en'] ?? '',
      generation: json['generation'] ?? '',
      types: List<String>.from(json['types'] ?? []),
      meta: PokemonMeta.fromJson(json['meta'] ?? {}),
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
      'meta': meta.toJson(),
    };
  }
}

class PokemonMeta {
  final String iconPosition;

  PokemonMeta({required this.iconPosition});

  factory PokemonMeta.fromJson(Map<String, dynamic> json) {
    return PokemonMeta(
      iconPosition: json['icon_position'] ?? '0px 0px',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'icon_position': iconPosition,
    };
  }
}
