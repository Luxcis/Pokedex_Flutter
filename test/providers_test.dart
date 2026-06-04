import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/models/ability_model.dart';
import 'package:pokedex/models/move_model.dart';
import 'package:pokedex/models/pokemon_detail_model.dart';
import 'package:pokedex/models/pokemon_model.dart';
import 'package:pokedex/providers/ability_provider.dart';
import 'package:pokedex/providers/fusion_provider.dart';
import 'package:pokedex/providers/move_provider.dart';
import 'package:pokedex/providers/pokemon_provider.dart';
import 'package:pokedex/utils/pokemon_data_cache.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PokemonProvider', () {
    test('初始状态', () {
      final provider = PokemonProvider();
      expect(provider.filteredPokemonList, isEmpty);
      expect(provider.allPokemonList, isEmpty);
      expect(provider.searchQuery, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNull);
      expect(provider.selectedTypes, isEmpty);
      expect(provider.selectedGenerations, isEmpty);
    });

    test('toggleType 多选上限为2', () {
      final provider = PokemonProvider();
      provider.toggleType('火');
      provider.toggleType('水');
      provider.toggleType('草');
      expect(provider.selectedTypes.length, 2);
      expect(provider.selectedTypes.contains('草'), isTrue);
      expect(provider.selectedTypes.contains('火'), isFalse);
    });

    test('toggleType 取消已选', () {
      final provider = PokemonProvider();
      provider.toggleType('火');
      provider.toggleType('火');
      expect(provider.selectedTypes, isEmpty);
    });

    test('toggleGeneration 单选切换', () {
      final provider = PokemonProvider();
      provider.toggleGeneration('第一世代');
      expect(provider.selectedGenerations.length, 1);
      provider.toggleGeneration('第二世代');
      expect(provider.selectedGenerations.length, 1);
      expect(provider.selectedGenerations.contains('第二世代'), isTrue);
    });

    test('toggleGeneration 取消选中', () {
      final provider = PokemonProvider();
      provider.toggleGeneration('第一世代');
      provider.toggleGeneration('第一世代');
      expect(provider.selectedGenerations, isEmpty);
    });

    test('resetFilters 清空所有筛选项', () {
      final provider = PokemonProvider();
      provider.toggleType('火');
      provider.toggleGeneration('第一世代');
      provider.resetFilters();
      expect(provider.selectedTypes, isEmpty);
      expect(provider.selectedGenerations, isEmpty);
    });

    test('searchPokemon trim+lowercase', () {
      final provider = PokemonProvider();
      provider.searchPokemon('  Pikachu  ');
      expect(provider.searchQuery, 'pikachu');
    });

    test('clearSearch 清空搜索词', () {
      final provider = PokemonProvider();
      provider.searchPokemon('test');
      provider.clearSearch();
      expect(provider.searchQuery, isEmpty);
    });
  });

  group('MoveProvider', () {
    test('初始状态', () {
      final provider = MoveProvider();
      expect(provider.filteredMoveList, isEmpty);
      expect(provider.allMoveList, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.selectedTypes, isEmpty);
      expect(provider.selectedGenerations, isEmpty);
      expect(provider.selectedCategories, isEmpty);
    });

    test('toggleCategory 单选切换', () {
      final provider = MoveProvider();
      provider.toggleCategory('物理');
      provider.toggleCategory('特殊');
      expect(provider.selectedCategories.length, 1);
      expect(provider.selectedCategories.contains('特殊'), isTrue);
    });

    test('toggleType 多选上限为2', () {
      final provider = MoveProvider();
      provider.toggleType('火');
      provider.toggleType('水');
      provider.toggleType('草');
      expect(provider.selectedTypes.length, 2);
    });

    test('resetFilters 清空所有', () {
      final provider = MoveProvider();
      provider.toggleType('火');
      provider.toggleGeneration('第一世代');
      provider.toggleCategory('物理');
      provider.resetFilters();
      expect(provider.selectedTypes, isEmpty);
      expect(provider.selectedGenerations, isEmpty);
      expect(provider.selectedCategories, isEmpty);
    });

    test('getMoveIndex 返回 null', () {
      final provider = MoveProvider();
      expect(provider.getMoveIndex('不存在的招式'), isNull);
    });
  });

  group('AbilityProvider', () {
    test('初始状态', () {
      final provider = AbilityProvider();
      expect(provider.filteredAbilityList, isEmpty);
      expect(provider.allAbilityList, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.selectedGenerations, isEmpty);
    });

    test('toggleGeneration 单选切换', () {
      final provider = AbilityProvider();
      provider.toggleGeneration('第一世代');
      provider.toggleGeneration('第二世代');
      expect(provider.selectedGenerations.length, 1);
    });

    test('resetFilters 清空世代选择', () {
      final provider = AbilityProvider();
      provider.toggleGeneration('第一世代');
      provider.resetFilters();
      expect(provider.selectedGenerations, isEmpty);
    });

    test('getAbilityIndex 返回 null', () {
      final provider = AbilityProvider();
      expect(provider.getAbilityIndex('不存在的特性'), isNull);
    });
  });

  group('FusionProvider', () {
    test('初始状态', () {
      final provider = FusionProvider();
      expect(provider.headPokemon, isNull);
      expect(provider.bodyPokemon, isNull);
      expect(provider.fusionResult, isNull);
      expect(provider.isLoading, false);
    });

    test('searchPokemon 空查询返回空列表', () {
      final provider = FusionProvider();
      final results = provider.searchPokemon('');
      expect(results, isEmpty);
    });
  });

  group('PokemonDataCache', () {
    test('单例模式', () {
      final cache1 = PokemonDataCache();
      final cache2 = PokemonDataCache();
      expect(identical(cache1, cache2), isTrue);
    });

    test('初始未加载状态', () {
      final cache = PokemonDataCache();
      expect(cache.isLoaded, isFalse);
    });
  });

  group('PokemonModel', () {
    test('fromJson 默认值处理', () {
      final model = PokemonModel.fromJson({});
      expect(model.index, '');
      expect(model.name, '');
      expect(model.types, []);
      expect(model.meta.iconPosition, '0px 0px');
    });

    test('fromJson/toJson 往返一致', () {
      final json = {
        'index': '0001',
        'name': '妙蛙种子',
        'name_jp': 'フシギダネ',
        'name_en': 'Bulbasaur',
        'generation': '第一世代',
        'types': ['草', '毒'],
        'meta': {'icon_position': '-56px -56px'},
      };
      final model = PokemonModel.fromJson(json);
      final restored = model.toJson();
      expect(restored['index'], '0001');
      expect(restored['name'], '妙蛙种子');
      expect(restored['types'], ['草', '毒']);
      expect(restored['meta']['icon_position'], '-56px -56px');
    });
  });

  group('MoveModel', () {
    test('fromJson 默认值处理', () {
      final model = MoveModel.fromJson({});
      expect(model.index, '');
      expect(model.name, '');
      expect(model.type, '');
      expect(model.category, '');
    });
  });

  group('AbilityModel', () {
    test('fromJson 默认值处理', () {
      final model = AbilityModel.fromJson({});
      expect(model.index, '');
      expect(model.name, '');
    });
  });

  group('PokemonDetailModel', () {
    test('fromJson 空数据', () {
      final model = PokemonDetailModel.fromJson({});
      expect(model.name, '');
      expect(model.index, '');
      expect(model.forms, isEmpty);
      expect(model.stats, isEmpty);
    });
  });
}
