import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokedex/models/fusion_pokemon_model.dart';

class FusionProvider extends ChangeNotifier {
  List<FusionPokemonModel> _allPokemonList = [];
  bool _isLoading = false;
  String? _errorMessage;
  FusionPokemonModel? _headPokemon;
  FusionPokemonModel? _bodyPokemon;
  FusionResult? _fusionResult;

  List<FusionPokemonModel> get allPokemonList => _allPokemonList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  FusionPokemonModel? get headPokemon => _headPokemon;
  FusionPokemonModel? get bodyPokemon => _bodyPokemon;
  FusionResult? get fusionResult => _fusionResult;

  Future<void> loadPokemonData() async {
    if (_allPokemonList.isNotEmpty) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/pokemon_fusion_data.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      _allPokemonList =
          jsonList.map((json) => FusionPokemonModel.fromJson(json)).toList();

      log('成功加载 ${_allPokemonList.length} 个宝可梦数据（融合计算器）');
    } catch (e) {
      _errorMessage = '加载数据失败: $e';
      log('加载融合宝可梦数据失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectHeadPokemon(FusionPokemonModel pokemon) {
    _headPokemon = pokemon;
    _calculateFusion();
  }

  void selectBodyPokemon(FusionPokemonModel pokemon) {
    _bodyPokemon = pokemon;
    _calculateFusion();
  }

  void swapPokemon() {
    final temp = _headPokemon;
    _headPokemon = _bodyPokemon;
    _bodyPokemon = temp;
    _calculateFusion();
  }

  void _calculateFusion() {
    if (_headPokemon == null || _bodyPokemon == null) {
      _fusionResult = null;
      notifyListeners();
      return;
    }

    final head = _headPokemon!;
    final body = _bodyPokemon!;

    final List<String> types = [];
    final headPrimaryType = head.types.isNotEmpty ? head.types[0] : '';
    types.add(headPrimaryType);

    String? bodySecondType;
    if (body.types.length >= 2) {
      bodySecondType = body.types[1];
    }

    if (bodySecondType != null && bodySecondType != headPrimaryType) {
      types.add(bodySecondType);
    } else {
      final bodyPrimaryType = body.types.isNotEmpty ? body.types[0] : '';
      if (bodyPrimaryType.isNotEmpty && bodyPrimaryType != headPrimaryType) {
        types.add(bodyPrimaryType);
      }
    }

    int fusedHp = ((head.hp * 2 / 3) + (body.hp * 1 / 3)).round();
    int fusedSpAttack = ((head.spAttack * 2 / 3) + (body.spAttack * 1 / 3)).round();
    int fusedSpDefense = ((head.spDefense * 2 / 3) + (body.spDefense * 1 / 3)).round();
    int fusedAttack = ((body.attack * 2 / 3) + (head.attack * 1 / 3)).round();
    int fusedDefense = ((body.defense * 2 / 3) + (head.defense * 1 / 3)).round();
    int fusedSpeed = ((body.speed * 2 / 3) + (head.speed * 1 / 3)).round();

    _fusionResult = FusionResult(
      types: types,
      hp: fusedHp,
      attack: fusedAttack,
      defense: fusedDefense,
      spAttack: fusedSpAttack,
      spDefense: fusedSpDefense,
      speed: fusedSpeed,
      headPokemon: head,
      bodyPokemon: body,
    );

    notifyListeners();
  }

  List<FusionPokemonModel> searchPokemon(String query) {
    if (query.trim().isEmpty) return _allPokemonList;
    final q = query.trim().toLowerCase();
    return _allPokemonList.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.nameEn.toLowerCase().contains(q) ||
          p.nameJp.toLowerCase().contains(q) ||
          p.index.contains(q);
    }).toList();
  }
}
