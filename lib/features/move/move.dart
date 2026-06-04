import 'package:flutter/material.dart';
import 'package:pokedex/features/move/move_detail_page.dart';
import 'package:pokedex/models/move_model.dart';
import 'package:pokedex/providers/move_provider.dart';
import 'package:pokedex/utils/move_category_colors.dart';
import 'package:pokedex/utils/pokemon_type_colors.dart';
import 'package:pokedex/widgets/category_chip.dart';
import 'package:pokedex/widgets/filter_button.dart';
import 'package:pokedex/widgets/selectable_chip.dart';
import 'package:pokedex/widgets/type_chip.dart';
import 'package:provider/provider.dart';

class MovePage extends StatefulWidget {
  const MovePage({super.key});

  @override
  State createState() => _MovePageState();
}

class _MovePageState extends State<MovePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoveProvider>().loadMoveData();
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
                    context.read<MoveProvider>().searchMove(text);
                  },
                ),
              ),
              const SizedBox(width: 8),
              FilterButton(onTap: () => _showMoveFilterDialog()),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<MoveProvider>(
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
                          onPressed: () => provider.loadMoveData(),
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.filteredMoveList.isEmpty) {
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
                          provider.searchQuery.isEmpty ? '暂无招式数据' : '未找到匹配的招式',
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
                  itemCount: provider.filteredMoveList.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    final move = provider.filteredMoveList[index];
                    return _buildMoveCard(move);
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

  // 弹出招式筛选面板：包含属性、世代、类别
  void _showMoveFilterDialog() {
    final provider = context.read<MoveProvider>();
    final Set<String> tempTypes = {...provider.selectedTypes};
    final Set<String> tempGens = {...provider.selectedGenerations};
    final Set<String> tempCats = {...provider.selectedCategories};

    final allTypes =
        {for (final m in provider.allMoveList) m.type}.toList()..sort();
    final allGens =
        {for (final m in provider.allMoveList) m.generation}.toList()..sort();
    final allCats =
        {for (final m in provider.allMoveList) m.category}.toList()..sort();

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
                                          final String first = tempTypes.first;
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
                        const SizedBox(height: 16),
                        const Text(
                          '类别',
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
                              allCats.map((c) {
                                final selected = tempCats.contains(c);
                                final color =
                                    selected
                                        ? MoveCategoryColors.getCategoryColor(c)
                                        : const Color(0xFFE0E0E0);
                                return SelectableChip(
                                  text: c,
                                  selected: selected,
                                  bgColor: color,
                                  onTap: () {
                                    setDialogState(() {
                                      if (selected) {
                                        tempCats.remove(c);
                                      } else {
                                        tempCats
                                          ..clear()
                                          ..add(c);
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
                                  for (final c in tempCats) {
                                    provider.toggleCategory(c);
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
                                    tempCats.clear();
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

  Widget _buildMoveCard(MoveModel move) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (_) => MoveDetailPage(
                    moveIndex: move.index,
                    moveName: move.name,
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  move.name,
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
                '#${move.index}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  TypeChip(type: move.type),
                  CategoryChip(category: move.category),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
