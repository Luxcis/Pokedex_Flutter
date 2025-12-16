import 'package:flutter/material.dart';

class PokemonTypeColors {
  static const Map<String, Color> typeColors = {
    '一般': Color(0xFF9FA19F),
    '火': Color(0xFFD33D35),
    '水': Color(0xFF437EE7),
    '草': Color(0xFF5B9F3D),
    '电': Color(0xFFF1C242),
    '冰': Color(0xFF70D5FB),
    '格斗': Color(0xFFEF8733),
    '毒': Color(0xFF8746C4),
    '地面': Color(0xFF88542B),
    '飞行': Color(0xFF8DB7EA),
    '超能力': Color(0xFFDC5078),
    '虫': Color(0xFF94A038),
    '岩石': Color(0xFFAEA985),
    '幽灵': Color(0xFF6A436D),
    '龙': Color(0xFF5360D9),
    '恶': Color(0xFF4E423F),
    '钢': Color(0xFF6F9FB5),
    '妖精': Color(0xFFDF77E9),
  };

  static Color getTypeColor(String type) {
    return typeColors[type] ?? Colors.grey;
  }
}
