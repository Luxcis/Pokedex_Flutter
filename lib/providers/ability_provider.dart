import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokedex/models/ability_detail_model.dart';
import 'package:pokedex/models/ability_model.dart';
import 'package:pokedex/utils/pokemon_data_cache.dart';

class AbilityProvider extends ChangeNotifier {
  List<AbilityModel> _allAbilityList = [];
  List<AbilityModel> _filteredAbilityList = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;
  final Set<String> _selectedGenerations = {};

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
      final String jsonString = await rootBundle.loadString(
        'assets/data/ability_list.json',
      );
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

  String? getAbilityIndex(String name) {
    final match = _allAbilityList.where((a) => a.name == name);
    return match.isNotEmpty ? match.first.index : null;
  }

  Future<AbilityDetailModel> loadAbilityDetail(String index,
      String name,) async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/ability/$index-$name.json',
      );
      final Map<String, dynamic> json =
          jsonDecode(jsonString) as Map<String, dynamic>;
      return AbilityDetailModel.fromJson(json);
    } catch (e) {
      log('加载特性详情失败 ($index-$name): $e');
      rethrow;
    }
  }

  Future<String?> getPokemonIconPosition(String pokemonIndex) async {
    final cache = PokemonDataCache();
    await cache.ensureLoaded();
    return cache.getIconPosition(pokemonIndex);
  }
}
