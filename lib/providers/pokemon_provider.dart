import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokedex/models/pokemon_model.dart';

class PokemonProvider extends ChangeNotifier {
  List<PokemonModel> _allPokemonList = [];
  List<PokemonModel> _filteredPokemonList = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;
  // 选中的筛选项：属性 与 世代
  final Set<String> _selectedTypes = {};
  final Set<String> _selectedGenerations = {};

  List<PokemonModel> get filteredPokemonList => _filteredPokemonList;
  List<PokemonModel> get allPokemonList => _allPokemonList;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Set<String> get selectedTypes => _selectedTypes;
  Set<String> get selectedGenerations => _selectedGenerations;

  // 加载宝可梦数据
  Future<void> loadPokemonData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/pokemon_full_list.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      _allPokemonList =
          jsonList.map((json) => PokemonModel.fromJson(json)).toList();
      _filteredPokemonList = _allPokemonList;

      log('成功加载 ${_allPokemonList.length} 个宝可梦数据');
    } catch (e) {
      _errorMessage = '加载数据失败: $e';
      log('加载宝可梦数据失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 搜索宝可梦
  void searchPokemon(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applyFilters();
  }

  /// 清空搜索
  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
  }

  /// 应用筛选逻辑：同时考虑搜索、属性、世代
  /// 规则：
  /// - 属性：若选择不为空，宝可梦需至少包含一个被选属性
  /// - 世代：若选择不为空，宝可梦的世代需命中其一
  void _applyFilters() {
    Iterable<PokemonModel> base = _allPokemonList;

    if (_searchQuery.isNotEmpty) {
      base = base.where((pokemon) {
        final q = _searchQuery;
        return pokemon.name.toLowerCase().contains(q) ||
            pokemon.nameEn.toLowerCase().contains(q) ||
            pokemon.nameJp.toLowerCase().contains(q) ||
            pokemon.index.toLowerCase().contains(q);
      });
    }

    if (_selectedTypes.isNotEmpty) {
      base = base.where((p) => p.types.any(_selectedTypes.contains));
    }

    if (_selectedGenerations.isNotEmpty) {
      base = base.where((p) => _selectedGenerations.contains(p.generation));
    }

    _filteredPokemonList = base.toList();
    notifyListeners();
  }

  /// 切换属性选择
  void toggleType(String type) {
    if (_selectedTypes.contains(type)) {
      _selectedTypes.remove(type);
    } else {
      _selectedTypes.add(type);
    }
    _applyFilters();
  }

  /// 切换世代选择
  void toggleGeneration(String generation) {
    if (_selectedGenerations.contains(generation)) {
      _selectedGenerations.remove(generation);
    } else {
      _selectedGenerations.add(generation);
    }
    _applyFilters();
  }

  /// 重置筛选
  void resetFilters() {
    _selectedTypes.clear();
    _selectedGenerations.clear();
    _applyFilters();
  }
}
