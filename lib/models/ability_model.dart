class AbilityModel {
  final String index;
  final String name;
  final String nameJp;
  final String nameEn;
  final String generation;

  const AbilityModel({
    required this.index,
    required this.name,
    required this.nameJp,
    required this.nameEn,
    required this.generation,
  });

  factory AbilityModel.fromJson(Map<String, dynamic> json) {
    return AbilityModel(
      index: json['index'] ?? '',
      name: json['name'] ?? '',
      nameJp: json['name_jp'] ?? '',
      nameEn: json['name_en'] ?? '',
      generation: json['generation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'name': name,
      'name_jp': nameJp,
      'name_en': nameEn,
      'generation': generation,
    };
  }
}
