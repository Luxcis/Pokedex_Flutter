import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokedex/models/move_model.dart';

class MoveProvider extends ChangeNotifier {
  List<MoveModel> _allMoveList = [];
  List<MoveModel> _filteredMoveList = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<MoveModel> get allMoveList => _allMoveList;
  List<MoveModel> get filteredMoveList => _filteredMoveList;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 加载招式数据
  Future<void> loadMoveData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/move_list.json');
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

  /// 搜索招式
  void searchMove(String query) {
    _searchQuery = query.trim().toLowerCase();

    if (_searchQuery.isEmpty) {
      _filteredMoveList = _allMoveList;
    } else {
      _filteredMoveList = _allMoveList.where((move) {
        return move.name.toLowerCase().contains(_searchQuery) ||
            move.nameEn.toLowerCase().contains(_searchQuery) ||
            move.nameJp.toLowerCase().contains(_searchQuery) ||
            move.index.toLowerCase().contains(_searchQuery) ||
            move.type.toLowerCase().contains(_searchQuery) ||
            move.category.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredMoveList = _allMoveList;
    notifyListeners();
  }
}