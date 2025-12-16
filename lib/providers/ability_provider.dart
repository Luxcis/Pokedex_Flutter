import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokedex/models/ability_model.dart';

class AbilityProvider extends ChangeNotifier {
  List<AbilityModel> _allAbilityList = [];
  List<AbilityModel> _filteredAbilityList = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<AbilityModel> get allAbilityList => _allAbilityList;
  List<AbilityModel> get filteredAbilityList => _filteredAbilityList;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 加载特性数据
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

  /// 搜索特性
  void searchAbility(String query) {
    _searchQuery = query.trim().toLowerCase();

    if (_searchQuery.isEmpty) {
      _filteredAbilityList = _allAbilityList;
    } else {
      _filteredAbilityList = _allAbilityList.where((ability) {
        return ability.name.toLowerCase().contains(_searchQuery) ||
            ability.nameEn.toLowerCase().contains(_searchQuery) ||
            ability.nameJp.toLowerCase().contains(_searchQuery) ||
            ability.index.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredAbilityList = _allAbilityList;
    notifyListeners();
  }
}