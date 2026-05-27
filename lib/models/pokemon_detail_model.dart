class PokemonDetailModel {
  final String name;
  final String index;
  final String nameEn;
  final String nameJp;
  final String profile;
  final List<PokemonFormModel> forms;
  final List<PokemonStatsGroupModel> stats;
  final List<PokemonFlavorTextGroupModel> flavorTexts;
  final List<List<PokemonEvolutionNodeModel>> evolutionChains;
  final Map<String, String> names;
  final PokemonMovesModel moves;
  final List<PokemonHomeImageModel> homeImages;

  bool get hasMultipleForms => forms.length >= 2;

  PokemonDetailModel({
    required this.name,
    required this.index,
    required this.nameEn,
    required this.nameJp,
    required this.profile,
    required this.forms,
    required this.stats,
    required this.flavorTexts,
    required this.evolutionChains,
    required this.names,
    required this.moves,
    required this.homeImages,
  });

  factory PokemonDetailModel.fromJson(Map<String, dynamic> json) {
    return PokemonDetailModel(
      name: json['name'] ?? '',
      index: json['index'] ?? '',
      nameEn: json['name_en'] ?? '',
      nameJp: json['name_jp'] ?? '',
      profile: json['profile'] ?? '',
      forms:
          (json['forms'] as List<dynamic>?)
              ?.map((f) => PokemonFormModel.fromJson(f))
              .toList() ??
          [],
      stats:
          (json['stats'] as List<dynamic>?)
              ?.map((s) => PokemonStatsGroupModel.fromJson(s))
              .toList() ??
          [],
      flavorTexts:
          (json['flavor_texts'] as List<dynamic>?)
              ?.map((ft) => PokemonFlavorTextGroupModel.fromJson(ft))
              .toList() ??
          [],
      evolutionChains:
          (json['evolution_chains'] as List<dynamic>?)
              ?.map(
                (chain) =>
                    (chain as List<dynamic>)
                        .map((n) => PokemonEvolutionNodeModel.fromJson(n))
                        .toList(),
              )
              .toList() ??
          [],
      names: Map<String, String>.from(json['names'] ?? {}),
      moves: PokemonMovesModel.fromJson(json['moves'] ?? {}),
      homeImages:
          (json['home_images'] as List<dynamic>?)
              ?.map((hi) => PokemonHomeImageModel.fromJson(hi))
              .toList() ??
          [],
    );
  }
}

class PokemonFormModel {
  final String name;
  final String index;
  final bool isMega;
  final bool isGmax;
  final String image;
  final List<String> types;
  final String genus;
  final List<PokemonAbilityModel> ability;
  final PokemonExperienceModel experience;
  final String height;
  final String weight;
  final PokemonGenderRateModel genderRate;
  final String shape;
  final String color;
  final PokemonCatchRateModel catchRate;
  final List<String> eggGroups;

  PokemonFormModel({
    required this.name,
    required this.index,
    required this.isMega,
    required this.isGmax,
    required this.image,
    required this.types,
    required this.genus,
    required this.ability,
    required this.experience,
    required this.height,
    required this.weight,
    required this.genderRate,
    required this.shape,
    required this.color,
    required this.catchRate,
    required this.eggGroups,
  });

  factory PokemonFormModel.fromJson(Map<String, dynamic> json) {
    return PokemonFormModel(
      name: json['name'] ?? '',
      index: json['index'] ?? '',
      isMega: json['is_mega'] ?? false,
      isGmax: json['is_gmax'] ?? false,
      image: json['image'] ?? '',
      types: List<String>.from(json['types'] ?? []),
      genus: json['genus'] ?? '',
      ability:
          (json['ability'] as List<dynamic>?)
              ?.map((a) => PokemonAbilityModel.fromJson(a))
              .toList() ??
          [],
      experience: PokemonExperienceModel.fromJson(json['experience'] ?? {}),
      height: json['height'] ?? '',
      weight: json['weight'] ?? '',
      genderRate: PokemonGenderRateModel.fromJson(json['gender_rate'] ?? {}),
      shape: json['shape'] ?? '',
      color: json['color'] ?? '',
      catchRate: PokemonCatchRateModel.fromJson(json['catch_rate'] ?? {}),
      eggGroups: List<String>.from(json['egg_groups'] ?? []),
    );
  }
}

class PokemonAbilityModel {
  final String name;
  final bool isHidden;

  PokemonAbilityModel({required this.name, required this.isHidden});

  factory PokemonAbilityModel.fromJson(Map<String, dynamic> json) {
    return PokemonAbilityModel(
      name: json['name'] ?? '',
      isHidden: json['is_hidden'] ?? false,
    );
  }
}

class PokemonExperienceModel {
  final String number;
  final String speed;

  PokemonExperienceModel({required this.number, required this.speed});

  factory PokemonExperienceModel.fromJson(Map<String, dynamic> json) {
    return PokemonExperienceModel(
      number: json['number'] ?? '',
      speed: json['speed'] ?? '',
    );
  }
}

class PokemonGenderRateModel {
  final String male;
  final String female;

  PokemonGenderRateModel({required this.male, required this.female});

  factory PokemonGenderRateModel.fromJson(Map<String, dynamic> json) {
    return PokemonGenderRateModel(
      male: json['male'] ?? '',
      female: json['female'] ?? '',
    );
  }
}

class PokemonCatchRateModel {
  final String number;
  final String rate;

  PokemonCatchRateModel({required this.number, required this.rate});

  factory PokemonCatchRateModel.fromJson(Map<String, dynamic> json) {
    return PokemonCatchRateModel(
      number: json['number'] ?? '',
      rate: json['rate'] ?? '',
    );
  }
}

class PokemonStatsGroupModel {
  final String form;
  final PokemonStatsDataModel data;

  PokemonStatsGroupModel({required this.form, required this.data});

  factory PokemonStatsGroupModel.fromJson(Map<String, dynamic> json) {
    return PokemonStatsGroupModel(
      form: json['form'] ?? '',
      data: PokemonStatsDataModel.fromJson(json['data'] ?? {}),
    );
  }
}

class PokemonStatsDataModel {
  final String hp;
  final String attack;
  final String defense;
  final String spAttack;
  final String spDefense;
  final String speed;

  PokemonStatsDataModel({
    required this.hp,
    required this.attack,
    required this.defense,
    required this.spAttack,
    required this.spDefense,
    required this.speed,
  });

  factory PokemonStatsDataModel.fromJson(Map<String, dynamic> json) {
    return PokemonStatsDataModel(
      hp: json['hp'] ?? '0',
      attack: json['attack'] ?? '0',
      defense: json['defense'] ?? '0',
      spAttack: json['sp_attack'] ?? '0',
      spDefense: json['sp_defense'] ?? '0',
      speed: json['speed'] ?? '0',
    );
  }

  List<PokemonStatItem> get items => [
    PokemonStatItem('HP', hp),
    PokemonStatItem('攻击', attack),
    PokemonStatItem('防御', defense),
    PokemonStatItem('特攻', spAttack),
    PokemonStatItem('特防', spDefense),
    PokemonStatItem('速度', speed),
  ];
}

class PokemonStatItem {
  final String label;
  final String value;

  PokemonStatItem(this.label, this.value);
}

class PokemonFlavorTextGroupModel {
  final String name;
  final List<PokemonFlavorTextVersionModel> versions;

  PokemonFlavorTextGroupModel({required this.name, required this.versions});

  factory PokemonFlavorTextGroupModel.fromJson(Map<String, dynamic> json) {
    return PokemonFlavorTextGroupModel(
      name: json['name'] ?? '',
      versions:
          (json['versions'] as List<dynamic>?)
              ?.map((v) => PokemonFlavorTextVersionModel.fromJson(v))
              .toList() ??
          [],
    );
  }
}

class PokemonFlavorTextVersionModel {
  final String name;
  final String group;
  final String text;

  PokemonFlavorTextVersionModel({
    required this.name,
    required this.group,
    required this.text,
  });

  factory PokemonFlavorTextVersionModel.fromJson(Map<String, dynamic> json) {
    return PokemonFlavorTextVersionModel(
      name: json['name'] ?? '',
      group: json['group'] ?? '',
      text: json['text'] ?? '',
    );
  }
}

class PokemonEvolutionNodeModel {
  final String name;
  final String stage;
  final String? text;
  final String image;
  final String? backText;
  final String? from;
  final String? formName;

  PokemonEvolutionNodeModel({
    required this.name,
    required this.stage,
    this.text,
    required this.image,
    this.backText,
    this.from,
    this.formName,
  });

  factory PokemonEvolutionNodeModel.fromJson(Map<String, dynamic> json) {
    return PokemonEvolutionNodeModel(
      name: json['name'] ?? '',
      stage: json['stage'] ?? '',
      text: json['text'],
      image: json['image'] ?? '',
      backText: json['back_text'],
      from: json['from'],
      formName: json['form_name'],
    );
  }
}

class PokemonMovesModel {
  final List<PokemonMoveGroupModel> learned;
  final List<PokemonMoveGroupModel> machine;

  PokemonMovesModel({required this.learned, required this.machine});

  factory PokemonMovesModel.fromJson(Map<String, dynamic> json) {
    return PokemonMovesModel(
      learned:
          (json['learned'] as List<dynamic>?)
              ?.map((l) => PokemonMoveGroupModel.fromJson(l))
              .toList() ??
          [],
      machine:
          (json['machine'] as List<dynamic>?)
              ?.map((m) => PokemonMoveGroupModel.fromJson(m))
              .toList() ??
          [],
    );
  }
}

class PokemonMoveGroupModel {
  final String form;
  final List<PokemonMoveDataModel> data;

  PokemonMoveGroupModel({required this.form, required this.data});

  factory PokemonMoveGroupModel.fromJson(Map<String, dynamic> json) {
    return PokemonMoveGroupModel(
      form: json['form'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((d) => PokemonMoveDataModel.fromJson(d))
              .toList() ??
          [],
    );
  }
}

class PokemonMoveDataModel {
  final String? levelLearnedAt;
  final String? machineUsed;
  final String method;
  final String name;
  final String flavorText;
  final String type;
  final String category;
  final String power;
  final String accuracy;
  final String pp;

  PokemonMoveDataModel({
    this.levelLearnedAt,
    this.machineUsed,
    required this.method,
    required this.name,
    required this.flavorText,
    required this.type,
    required this.category,
    required this.power,
    required this.accuracy,
    required this.pp,
  });

  factory PokemonMoveDataModel.fromJson(Map<String, dynamic> json) {
    return PokemonMoveDataModel(
      levelLearnedAt: json['level_learned_at'],
      machineUsed: json['machine_used'],
      method: json['method'] ?? '',
      name: json['name'] ?? '',
      flavorText: json['flavor_text'] ?? '',
      type: json['type'] ?? '',
      category: json['category'] ?? '',
      power: json['power'] ?? '',
      accuracy: json['accuracy'] ?? '',
      pp: json['pp'] ?? '',
    );
  }
}

class PokemonHomeImageModel {
  final String name;
  final String image;
  final String shiny;

  PokemonHomeImageModel({
    required this.name,
    required this.image,
    required this.shiny,
  });

  factory PokemonHomeImageModel.fromJson(Map<String, dynamic> json) {
    return PokemonHomeImageModel(
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      shiny: json['shiny'] ?? '',
    );
  }
}
