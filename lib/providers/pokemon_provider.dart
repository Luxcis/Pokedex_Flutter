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

  List<PokemonModel> get filteredPokemonList => _filteredPokemonList;
  List<PokemonModel> get allPokemonList => _allPokemonList;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 加载宝可梦数据
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

    if (_searchQuery.isEmpty) {
      _filteredPokemonList = _allPokemonList;
    } else {
      _filteredPokemonList = _allPokemonList.where((pokemon) {
        return pokemon.name.toLowerCase().contains(_searchQuery) ||
            pokemon.nameEn.toLowerCase().contains(_searchQuery) ||
            pokemon.nameJp.toLowerCase().contains(_searchQuery) ||
            pokemon.index.contains(_searchQuery);
      }).toList();
    }

    notifyListeners();
  }

  /// 清空搜索
  void clearSearch() {
    _searchQuery = '';
    _filteredPokemonList = _allPokemonList;
    notifyListeners();
  }
}
