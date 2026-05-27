import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokedex/models/ability_detail_model.dart';
import 'package:pokedex/models/ability_model.dart';

class AbilityProvider extends ChangeNotifier {
  List<AbilityModel> _allAbilityList = [];
  List<AbilityModel> _filteredAbilityList = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;
  // 选中的筛选项：世代
  final Set<String> _selectedGenerations = {};

  final Map<String, String> _pokemonIconMap = {};

  List<AbilityModel> get allAbilityList => _allAbilityList;
  List<AbilityModel> get filteredAbilityList => _filteredAbilityList;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Set<String> get selectedGenerations => _selectedGenerations;

  // 加载特性数据
  Future<void> loadAbilityData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/ability_list.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      _allAbilityList =
          jsonList.map((json) => AbilityModel.fromJson(json)).toList();
      _filteredAbilityList = _allAbilityList;

      log('成功加载 ${_allAbilityList.length} 个特性数据');
    } catch (e) {
      _errorMessage = '加载数据失败: $e';
      log('加载特性数据失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 搜索特性
  void searchAbility(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applyFilters();
  }

  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
  }

  // 应用筛选逻辑：同时考虑搜索与世代
  void _applyFilters() {
    Iterable<AbilityModel> base = _allAbilityList;

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery;
      base = base.where((ability) {
        return ability.name.toLowerCase().contains(q) ||
            ability.nameEn.toLowerCase().contains(q) ||
            ability.nameJp.toLowerCase().contains(q) ||
            ability.index.toLowerCase().contains(q);
      });
    }

    if (_selectedGenerations.isNotEmpty) {
      base = base.where((a) => _selectedGenerations.contains(a.generation));
    }

    _filteredAbilityList = base.toList();
    notifyListeners();
  }

  // 切换世代选择（单选，可取消）
  void toggleGeneration(String generation) {
    if (_selectedGenerations.contains(generation)) {
      _selectedGenerations.remove(generation);
    } else {
      _selectedGenerations
        ..clear()
        ..add(generation);
    }
    _applyFilters();
  }

  void resetFilters() {
    _selectedGenerations.clear();
    _applyFilters();
  }

  Future<AbilityDetailModel> loadAbilityDetail(
      String index, String name) async {
    try {
      final String jsonString = await rootBundle
          .loadString('assets/data/ability/$index-$name.json');
      final Map<String, dynamic> json =
          jsonDecode(jsonString) as Map<String, dynamic>;
      return AbilityDetailModel.fromJson(json);
    } catch (e) {
      log('加载特性详情失败 ($index-$name): $e');
      rethrow;
    }
  }

  Future<String?> getPokemonIconPosition(String pokemonIndex) async {
    if (_pokemonIconMap.isEmpty) {
      await _loadPokemonIconMap();
    }
    return _pokemonIconMap[pokemonIndex];
  }

  Future<void> _loadPokemonIconMap() async {
    try {
      final String jsonString = await rootBundle
          .loadString('assets/data/pokemon_full_list.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      for (final entry in jsonList) {
        final idx = entry['index'] as String? ?? '';
        final meta = entry['meta'] as Map<String, dynamic>?;
        final iconPos = meta?['icon_position'] as String? ?? '';
        if (idx.isNotEmpty) {
          _pokemonIconMap[idx] = iconPos;
        }
      }
    } catch (e) {
      log('加载宝可梦精灵图数据失败: $e');
    }
  }
}