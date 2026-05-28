import 'dart:convert';

import 'package:flutter/services.dart';

class PokemonDataCache {
  static PokemonDataCache? _instance;

  factory PokemonDataCache() {
    _instance ??= PokemonDataCache._();
    return _instance!;
  }

  PokemonDataCache._();

  Map<String, String>? _iconMap;
  Map<String, List<String>>? _typesMap;
  bool _isLoading = false;

  bool get isLoaded => _iconMap != null;

  Future<void> ensureLoaded() async {
    if (_iconMap != null) return;
    if (_isLoading) return;
    _isLoading = true;

    final iconMap = <String, String>{};
    final typesMap = <String, List<String>>{};

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/pokemon_full_list.json',
      );
      final List<dynamic> jsonList = jsonDecode(jsonString);
      for (final entry in jsonList) {
        final idx = entry['index'] as String? ?? '';
        final meta = entry['meta'] as Map<String, dynamic>?;
        final iconPos = meta?['icon_position'] as String? ?? '';
        final types = List<String>.from(entry['types'] as List<dynamic>? ?? []);
        if (idx.isNotEmpty) {
          iconMap[idx] = iconPos;
          typesMap[idx] = types;
        }
      }
      _iconMap = iconMap;
      _typesMap = typesMap;
    } catch (_) {
    } finally {
      _isLoading = false;
    }
  }

  String? getIconPosition(String index) => _iconMap?[index];

  List<String> getTypes(String index) => _typesMap?[index] ?? [];
}
