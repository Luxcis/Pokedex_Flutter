class MoveDetailModel {
  final String index;
  final String generation;
  final String name;
  final String nameJp;
  final String nameEn;
  final String type;
  final String category;
  final String power;
  final String accuracy;
  final String pp;
  final String text;
  final String effect;
  final List<String> info;
  final String range;
  final MovePokemonGroups pokemon;

  const MoveDetailModel({
    required this.index,
    required this.generation,
    required this.name,
    required this.nameJp,
    required this.nameEn,
    required this.type,
    required this.category,
    required this.power,
    required this.accuracy,
    required this.pp,
    required this.text,
    required this.effect,
    required this.info,
    required this.range,
    required this.pokemon,
  });

  factory MoveDetailModel.fromJson(Map<String, dynamic> json) {
    return MoveDetailModel(
      index: json['index'] ?? '',
      generation: json['generation'] ?? '',
      name: json['name'] ?? '',
      nameJp: json['name_jp'] ?? '',
      nameEn: json['name_en'] ?? '',
      type: json['type'] ?? '',
      category: json['category'] ?? '',
      power: json['power'] ?? '',
      accuracy: json['accuracy'] ?? '',
      pp: json['pp'] ?? '',
      text: json['text'] ?? '',
      effect: json['effect'] ?? '',
      info: List<String>.from(json['info'] ?? []),
      range: json['range'] ?? '',
      pokemon: MovePokemonGroups.fromJson(
        json['pokemon'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'generation': generation,
      'name': name,
      'name_jp': nameJp,
      'name_en': nameEn,
      'type': type,
      'category': category,
      'power': power,
      'accuracy': accuracy,
      'pp': pp,
      'text': text,
      'effect': effect,
      'info': info,
      'range': range,
      'pokemon': pokemon.toJson(),
    };
  }
}

class MovePokemonGroups {
  final List<MovePokemon> level;
  final List<MovePokemon> machine;
  final List<MovePokemon> egg;
  final List<MovePokemon> tutor;

  const MovePokemonGroups({
    required this.level,
    required this.machine,
    required this.egg,
    required this.tutor,
  });

  factory MovePokemonGroups.fromJson(Map<String, dynamic> json) {
    return MovePokemonGroups(
      level:
          (json['level'] as List<dynamic>?)
              ?.map((p) => MovePokemon.fromJson(p))
              .toList() ??
          [],
      machine:
          (json['machine'] as List<dynamic>?)
              ?.map((p) => MovePokemon.fromJson(p))
              .toList() ??
          [],
      egg:
          (json['egg'] as List<dynamic>?)
              ?.map((p) => MovePokemon.fromJson(p))
              .toList() ??
          [],
      tutor:
          (json['tutor'] as List<dynamic>?)
              ?.map((p) => MovePokemon.fromJson(p))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level.map((p) => p.toJson()).toList(),
      'machine': machine.map((p) => p.toJson()).toList(),
      'egg': egg.map((p) => p.toJson()).toList(),
      'tutor': tutor.map((p) => p.toJson()).toList(),
    };
  }
}

class MovePokemon {
  final String index;
  final String name;

  const MovePokemon({required this.index, required this.name});

  factory MovePokemon.fromJson(Map<String, dynamic> json) {
    return MovePokemon(index: json['index'] ?? '', name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'index': index, 'name': name};
  }
}
