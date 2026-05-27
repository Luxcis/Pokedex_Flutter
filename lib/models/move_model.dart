class MoveModel {
  final String index;
  final String name;
  final String nameJp;
  final String nameEn;
  final String generation;
  final String type;
  final String category;

  const MoveModel({
    required this.index,
    required this.name,
    required this.nameJp,
    required this.nameEn,
    required this.generation,
    required this.type,
    required this.category,
  });

  factory MoveModel.fromJson(Map<String, dynamic> json) {
    return MoveModel(
      index: json['index'] ?? '',
      name: json['name'] ?? '',
      nameJp: json['name_jp'] ?? '',
      nameEn: json['name_en'] ?? '',
      generation: json['generation'] ?? '',
      type: json['type'] ?? '',
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'name': name,
      'name_jp': nameJp,
      'name_en': nameEn,
      'generation': generation,
      'type': type,
      'category': category,
    };
  }
}
