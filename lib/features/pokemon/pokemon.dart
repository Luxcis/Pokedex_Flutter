import 'package:flutter/material.dart';
import 'package:pokedex/features/pokemon/pokemon_detail_page.dart';
import 'package:pokedex/features/pokemon/widgets/pokemon_sprite_icon.dart';
import 'package:pokedex/models/pokemon_model.dart';
import 'package:pokedex/providers/pokemon_provider.dart';
import 'package:pokedex/utils/pokemon_type_colors.dart';
import 'package:pokedex/widgets/filter_button.dart';
import 'package:pokedex/widgets/selectable_chip.dart';
import 'package:pokedex/widgets/type_chip.dart';
import 'package:provider/provider.dart';

class PokemonPage extends StatefulWidget {
  const PokemonPage({super.key});

  @override
  State createState() => _PokemonPageState();
}

class _PokemonPageState extends State<PokemonPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PokemonProvider>().loadPokemonData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '搜索',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  ),
                  onChanged: (text) {
                    context.read<PokemonProvider>().searchPokemon(text);
                  },
                ),
              ),
              const SizedBox(width: 8),
              FilterButton(onTap: () => _showPokemonFilterDialog()),
            ],
          ),
        ),
        actions: const [],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<PokemonProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.errorMessage!,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.loadPokemonData(),
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.filteredPokemonList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.searchQuery.isEmpty
                              ? '暂无宝可梦数据'
                              : '未找到匹配的宝可梦',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: provider.filteredPokemonList.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    final pokemon = provider.filteredPokemonList[index];
                    return _buildPokemonCard(pokemon);
                  },
                );
              },
            ),
          ),
          Container(
            height: 1,
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  void _showPokemonFilterDialog() {
    final provider = context.read<PokemonProvider>();
    final Set<String> tempTypes = {...provider.selectedTypes};
    final Set<String> tempGens = {...provider.selectedGenerations};

    final allTypes = <String>{
      for (final p in provider.allPokemonList) ...p.types,
    }.toList()
      ..sort();
    final allGens = <String>{
      for (final p in provider.allPokemonList) p.generation,
    }.toList()
      ..sort();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                '筛选',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '属性（已选 ${tempTypes.length}/2）',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              allTypes.map((t) {
                                final selected = tempTypes.contains(t);
                                final color =
                                    selected
                                        ? PokemonTypeColors.getTypeColor(t)
                                        : const Color(0xFFE0E0E0);
                                return SelectableChip(
                                  text: t,
                                  selected: selected,
                                  bgColor: color,
                                  onTap: () {
                                    setDialogState(() {
                                      if (selected) {
                                        tempTypes.remove(t);
                                      } else {
                                        if (tempTypes.length >= 2) {
                                          final String first =
                                              tempTypes.first;
                                          tempTypes.remove(first);
                                        }
                                        tempTypes.add(t);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '世代',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              allGens.map((g) {
                                final selected = tempGens.contains(g);
                                final color =
                                    selected
                                        ? Colors.black
                                        : const Color(0xFFE0E0E0);
                                return SelectableChip(
                                  text: g,
                                  selected: selected,
                                  bgColor: color,
                                  onTap: () {
                                    setDialogState(() {
                                      if (selected) {
                                        tempGens.remove(g);
                                      } else {
                                        tempGens
                                          ..clear()
                                          ..add(g);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  provider.resetFilters();
                                  for (final t in tempTypes) {
                                    provider.toggleType(t);
                                  }
                                  for (final g in tempGens) {
                                    provider.toggleGeneration(g);
                                  }
                                  Navigator.of(ctx).pop();
                                },
                                child: const Text('应用'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setDialogState(() {
                                    tempTypes.clear();
                                    tempGens.clear();
                                  });
                                  provider.resetFilters();
                                },
                                child: const Text('重置'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPokemonCard(PokemonModel pokemon) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => PokemonDetailPage(
                    pokemonIndex: pokemon.index,
                    pokemonName: pokemon.name,
                  ),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: PokemonSpriteIcon(
          iconPosition: pokemon.meta.iconPosition,
          size: 56,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                pokemon.name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '#${pokemon.index}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${pokemon.nameJp} / ${pokemon.nameEn}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children:
              pokemon.types.map((type) => TypeChip(type: type)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
