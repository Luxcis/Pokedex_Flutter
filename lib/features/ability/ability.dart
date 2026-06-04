import 'package:flutter/material.dart';
import 'package:pokedex/features/ability/ability_detail_page.dart';
import 'package:pokedex/models/ability_model.dart';
import 'package:pokedex/providers/ability_provider.dart';
import 'package:pokedex/widgets/filter_button.dart';
import 'package:pokedex/widgets/selectable_chip.dart';
import 'package:provider/provider.dart';

class AbilityPage extends StatefulWidget {
  const AbilityPage({super.key});

  @override
  State createState() => _AbilityPageState();
}

class _AbilityPageState extends State<AbilityPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AbilityProvider>().loadAbilityData();
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
                    context.read<AbilityProvider>().searchAbility(text);
                  },
                ),
              ),
              const SizedBox(width: 8),
              FilterButton(onTap: () => _showAbilityFilterDialog()),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<AbilityProvider>(
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
                          onPressed: () => provider.loadAbilityData(),
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.filteredAbilityList.isEmpty) {
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
                          provider.searchQuery.isEmpty ? '暂无特性数据' : '未找到匹配的特性',
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
                  itemCount: provider.filteredAbilityList.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    final ability = provider.filteredAbilityList[index];
                    return _buildAbilityCard(ability);
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

  // 弹出特性筛选面板：仅包含世代，单选
  void _showAbilityFilterDialog() {
    final provider = context.read<AbilityProvider>();
    final Set<String> tempGens = {...provider.selectedGenerations};

    final allGens =
        {for (final a in provider.allAbilityList) a.generation}.toList()
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
            );
          },
        );
      },
    );
  }

  Widget _buildAbilityCard(AbilityModel ability) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => AbilityDetailPage(
                    abilityIndex: ability.index,
                    abilityName: ability.name,
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
                  ability.name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '#${ability.index}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
