import 'package:flutter/material.dart';

class MoveCategoryColors {
  static const Map<String, Color> categoryColors = {
    '物理': Color(0xFFEB5428),
    '特殊': Color(0xFF3665C5),
    '变化': Color(0xFF999999),
    '极巨': Color(0xFF9F409A),
    '超极巨': Color(0xFF9F409A),
  };

  static Color getCategoryColor(String category) {
    return categoryColors[category] ?? Colors.grey;
  }
}