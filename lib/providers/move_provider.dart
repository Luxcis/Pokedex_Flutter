import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokedex/models/move_detail_model.dart';
import 'package:pokedex/models/move_model.dart';
import 'package:pokedex/utils/pokemon_data_cache.dart';

class MoveProvider extends ChangeNotifier {
  List<MoveModel> _allMoveList = [];
  List<MoveModel> _filteredMoveList = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;
  // 选中的筛选项：属性、世代、类别
  final Set<String> _selectedTypes = {};
  final Set<String> _selectedGenerations = {};
  final Set<String> _selectedCategories = {};

  List<MoveModel> get allMoveList => _allMoveList;
  List<MoveModel> get filteredMoveList => _filteredMoveList;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Set<String> get selectedTypes => _selectedTypes;
  Set<String> get selectedGenerations => _selectedGenerations;
  Set<String> get selectedCategories => _selectedCategories;

  // 加载招式数据
  Future<void> loadMoveData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/move_list.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);

      _allMoveList = jsonList.map((json) => MoveModel.fromJson(json)).toList();
      _filteredMoveList = _allMoveList;

      log('成功加载 ${_allMoveList.length} 个招式数据');
    } catch (e) {
      _errorMessage = '加载数据失败: $e';
      log('加载招式数据失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 搜索招式
  void searchMove(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applyFilters();
  }

  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
  }

  // 应用筛选逻辑：同时考虑搜索、属性、世代、类别
  void _applyFilters() {
    Iterable<MoveModel> base = _allMoveList;

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery;
      base = base.where((move) {
        return move.name.toLowerCase().contains(q) ||
            move.nameEn.toLowerCase().contains(q) ||
            move.nameJp.toLowerCase().contains(q) ||
            move.index.toLowerCase().contains(q) ||
            move.type.toLowerCase().contains(q) ||
            move.category.toLowerCase().contains(q);
      });
    }

    if (_selectedTypes.isNotEmpty) {
      base = base.where((m) => _selectedTypes.contains(m.type));
    }
    if (_selectedGenerations.isNotEmpty) {
      base = base.where((m) => _selectedGenerations.contains(m.generation));
    }
    if (_selectedCategories.isNotEmpty) {
      base = base.where((m) => _selectedCategories.contains(m.category));
    }

    _filteredMoveList = base.toList();
    notifyListeners();
  }

  // 切换属性选择（最多2个，超出移除最早）
  void toggleType(String type) {
    if (_selectedTypes.contains(type)) {
      _selectedTypes.remove(type);
    } else {
      if (_selectedTypes.length >= 2) {
        final String first = _selectedTypes.first;
        _selectedTypes.remove(first);
      }
      _selectedTypes.add(type);
    }
    _applyFilters();
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

  // 切换类别选择（单选，可取消）
  void toggleCategory(String category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories
        ..clear()
        ..add(category);
    }
    _applyFilters();
  }

  // 重置筛选
  void resetFilters() {
    _selectedTypes.clear();
    _selectedGenerations.clear();
    _selectedCategories.clear();
    _applyFilters();
  }

  Future<String?> getPokemonIconPosition(String pokemonIndex) async {
    final cache = PokemonDataCache();
    await cache.ensureLoaded();
    return cache.getIconPosition(pokemonIndex);
  }

  Future<List<String>> getPokemonTypes(String pokemonIndex) async {
    final cache = PokemonDataCache();
    await cache.ensureLoaded();
    return cache.getTypes(pokemonIndex);
  }

  String? getMoveIndex(String name) {
    final match = _allMoveList.where((m) => m.name == name);
    return match.isNotEmpty ? match.first.index : null;
  }

  Future<MoveDetailModel> loadMoveDetail(String index, String name) async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/move/$index-$name.json',
      );
      final Map<String, dynamic> json =
          jsonDecode(jsonString) as Map<String, dynamic>;
      return MoveDetailModel.fromJson(json);
    } catch (e) {
      log('加载招式详情失败 ($index-$name): $e');
      rethrow;
    }
  }
}
