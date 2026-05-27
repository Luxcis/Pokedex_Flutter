class TypeEffectiveness {
  static const _typeIndex = {
    '一般': 0, '火': 1, '水': 2, '草': 3, '电': 4, '冰': 5,
    '格斗': 6, '毒': 7, '地面': 8, '飞行': 9, '超能力': 10, '虫': 11,
    '岩石': 12, '幽灵': 13, '龙': 14, '恶': 15, '钢': 16, '妖精': 17,
  };

  static const List<String> allTypes = [
    '一般', '火', '水', '草', '电', '冰',
    '格斗', '毒', '地面', '飞行', '超能力', '虫',
    '岩石', '幽灵', '龙', '恶', '钢', '妖精',
  ];

  static const _chart = [
    [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0],
    [1.0, 0.5, 2.0, 0.5, 1.0, 0.5, 1.0, 1.0, 2.0, 1.0, 1.0, 0.5, 2.0, 1.0, 1.0, 1.0, 0.5, 0.5],
    [1.0, 0.5, 0.5, 2.0, 2.0, 0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.5, 1.0],
    [1.0, 2.0, 0.5, 0.5, 0.5, 2.0, 1.0, 2.0, 0.5, 2.0, 1.0, 2.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0],
    [1.0, 1.0, 1.0, 1.0, 0.5, 1.0, 1.0, 1.0, 2.0, 0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.5, 1.0],
    [1.0, 2.0, 1.0, 1.0, 1.0, 0.5, 2.0, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 1.0, 1.0, 1.0, 2.0, 1.0],
    [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.5, 0.5, 1.0, 0.5, 2.0, 1.0, 1.0, 1.0, 1.0, 0.5, 1.0, 2.0],
    [1.0, 1.0, 1.0, 0.5, 1.0, 1.0, 0.5, 0.5, 2.0, 1.0, 2.0, 0.5, 0.5, 1.0, 1.0, 1.0, 1.0, 0.5],
    [1.0, 1.0, 2.0, 2.0, 0.0, 2.0, 1.0, 0.5, 1.0, 1.0, 1.0, 1.0, 0.5, 1.0, 1.0, 1.0, 1.0, 1.0],
    [1.0, 1.0, 1.0, 0.5, 2.0, 2.0, 0.5, 1.0, 0.0, 1.0, 1.0, 0.5, 2.0, 1.0, 1.0, 1.0, 1.0, 1.0],
    [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.5, 1.0, 1.0, 1.0, 0.5, 2.0, 1.0, 2.0, 1.0, 2.0, 1.0, 1.0],
    [1.0, 2.0, 1.0, 0.5, 1.0, 1.0, 0.5, 1.0, 0.5, 2.0, 1.0, 1.0, 2.0, 1.0, 1.0, 1.0, 1.0, 1.0],
    [0.5, 0.5, 2.0, 2.0, 1.0, 1.0, 0.5, 0.5, 2.0, 0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 1.0],
    [0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.5, 1.0, 1.0, 1.0, 0.5, 1.0, 2.0, 1.0, 2.0, 1.0, 1.0],
    [1.0, 0.5, 0.5, 0.5, 0.5, 2.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 1.0, 1.0, 2.0],
    [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 1.0, 1.0, 1.0, 0.0, 2.0, 1.0, 0.5, 1.0, 0.5, 1.0, 2.0],
    [0.5, 2.0, 1.0, 0.5, 1.0, 0.5, 2.0, 0.0, 2.0, 0.5, 0.5, 0.5, 0.5, 1.0, 0.5, 1.0, 0.5, 0.5],
    [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.5, 2.0, 1.0, 1.0, 1.0, 0.5, 1.0, 1.0, 0.0, 0.5, 2.0, 1.0],
  ];

  static double getEffectiveness(String attackType, String defendType) {
    final attackIdx = _typeIndex[attackType];
    final defendIdx = _typeIndex[defendType];
    if (attackIdx == null || defendIdx == null) return 1.0;
    return _chart[defendIdx][attackIdx];
  }

  static double getCombinedEffectiveness(String attackType, List<String> defendTypes) {
    double multiplier = 1.0;
    for (final dt in defendTypes) {
      multiplier *= getEffectiveness(attackType, dt);
    }
    return multiplier;
  }

  static Map<String, List<String>> getTypeEffectivenessCategories(List<String> defendTypes) {
    final superEffective = <String>[];
    final normal = <String>[];
    final notVeryEffective = <String>[];
    final noEffect = <String>[];

    for (final atkType in allTypes) {
      final mult = getCombinedEffectiveness(atkType, defendTypes);
      if (mult == 0.0) {
        noEffect.add(atkType);
      } else if (mult > 1.0) {
        superEffective.add(atkType);
      } else if (mult < 1.0) {
        notVeryEffective.add(atkType);
      } else {
        normal.add(atkType);
      }
    }

    return {
      'superEffective': superEffective,
      'normal': normal,
      'notVeryEffective': notVeryEffective,
      'noEffect': noEffect,
    };
  }
}

class TypeEffectResult {
  final String type;
  final double multiplier;

  const TypeEffectResult({required this.type, required this.multiplier});
}

class TypeEffectivenessChart {
  static const List<String> selectableTypes = TypeEffectiveness.allTypes;

  static List<TypeEffectResult> getDefenderChart(List<String> defendTypes) {
    final results = <TypeEffectResult>[];
    for (final atkType in TypeEffectiveness.allTypes) {
      final mult = TypeEffectiveness.getCombinedEffectiveness(atkType, defendTypes);
      results.add(TypeEffectResult(type: atkType, multiplier: mult));
    }
    return results;
  }

  static List<TypeEffectResult> getAttackerChart(String attackType) {
    final results = <TypeEffectResult>[];
    for (final defType in TypeEffectiveness.allTypes) {
      final mult = TypeEffectiveness.getEffectiveness(attackType, defType);
      results.add(TypeEffectResult(type: defType, multiplier: mult));
    }
    return results;
  }
}
