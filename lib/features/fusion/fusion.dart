import 'package:flutter/material.dart';
import 'package:pokedex/features/pokemon/widgets/pokemon_sprite_icon.dart';
import 'package:pokedex/models/fusion_pokemon_model.dart';
import 'package:pokedex/providers/fusion_provider.dart';
import 'package:pokedex/utils/pokemon_type_colors.dart';
import 'package:pokedex/utils/type_effectiveness.dart';
import 'package:pokedex/widgets/type_chip.dart';
import 'package:provider/provider.dart';

class FusionPage extends StatefulWidget {
  const FusionPage({super.key});

  @override
  State createState() => _FusionPageState();
}

class _FusionPageState extends State<FusionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FusionProvider>().loadPokemonData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(scrolledUnderElevation: 0, title: const Text('融合计算器')),
      body: Consumer<FusionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    style: const TextStyle(fontSize: 16),
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

          if (provider.allPokemonList.isEmpty) {
            return const Center(child: Text('暂无宝可梦数据'));
          }

          return _buildFusionLayout(provider);
        },
      ),
    );
  }

  Widget _buildFusionLayout(FusionProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSelectorRow(provider),
          const SizedBox(height: 24),
          if (provider.fusionResult != null) ...[
            _buildFusionResult(provider.fusionResult!),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectorRow(FusionProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final slotWidth =
            isWide
                ? (constraints.maxWidth - 64) / 2
                : constraints.maxWidth - 32;

        if (isWide) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: slotWidth,
                child: _buildPokemonSlot(
                  label: '头部',
                  pokemon: provider.headPokemon,
                  onTap: () => _showPokemonPicker(true),
                  onClear: () => _showPokemonPicker(true),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 32,
                ),
                child: IconButton(
                  onPressed:
                      (provider.headPokemon != null &&
                              provider.bodyPokemon != null)
                          ? () => provider.swapPokemon()
                          : null,
                  icon: Icon(Icons.swap_horiz, color: Colors.grey[600]),
                  tooltip: '交换',
                ),
              ),
              SizedBox(
                width: slotWidth,
                child: _buildPokemonSlot(
                  label: '身体',
                  pokemon: provider.bodyPokemon,
                  onTap: () => _showPokemonPicker(false),
                  onClear: () => _showPokemonPicker(false),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            _buildPokemonSlot(
              label: '头部',
              pokemon: provider.headPokemon,
              onTap: () => _showPokemonPicker(true),
              onClear: () => _showPokemonPicker(true),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed:
                        (provider.headPokemon != null &&
                                provider.bodyPokemon != null)
                            ? () => provider.swapPokemon()
                            : null,
                    icon: Icon(Icons.swap_vert, color: Colors.grey[600]),
                    tooltip: '交换',
                  ),
                ],
              ),
            ),
            _buildPokemonSlot(
              label: '身体',
              pokemon: provider.bodyPokemon,
              onTap: () => _showPokemonPicker(false),
              onClear: () => _showPokemonPicker(false),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPokemonSlot({
    required String label,
    required FusionPokemonModel? pokemon,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              pokemon != null
                  ? Row(
                    children: [
                      PokemonSpriteIcon(
                        iconPosition: pokemon.iconPosition,
                        size: 56,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
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
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${pokemon.nameJp} / ${pokemon.nameEn}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children:
                                  pokemon.types
                                      .map((t) => TypeChip(type: t))
                                      .toList(),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onClear,
                        icon: const Icon(Icons.close, size: 20),
                      ),
                    ],
                  )
                  : SizedBox(
                    height: 96,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Icon(
                            Icons.add_circle_outline,
                            size: 32,
                            color: colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildFusionResult(FusionResult result) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        Center(
          child: Text(
            '融合结果',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            '${result.headPokemon.name} (头) + ${result.bodyPokemon.name} (身)',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
        const SizedBox(height: 16),
        _buildTypeSection(result),
        const SizedBox(height: 24),
        _buildStatsSection(result),
        const SizedBox(height: 24),
        _buildTypeEffectivenessSection(result),
      ],
    );
  }

  Widget _buildTypeSection(FusionResult result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Text(
              '融合属性',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 12),
            ...result.types.map(
              (t) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: TypeChip(type: t),
              ),
            ),
            const Spacer(),
            Text(
              result.types.length == 1 ? '单属性' : '双属性',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(FusionResult result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '种族值',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  '总和: ${result.totalStats}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatBar('HP', result.hp),
            _buildStatBar('攻击', result.attack),
            _buildStatBar('防御', result.defense),
            _buildStatBar('特攻', result.spAttack),
            _buildStatBar('特防', result.spDefense),
            _buildStatBar('速度', result.speed),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBar(String label, int value) {
    final double progress = (value / 255.0).clamp(0.0, 1.0);
    final Color barColor =
        progress > 0.6
            ? Colors.green
            : progress > 0.4
            ? Colors.orange
            : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
                minHeight: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: Text(
              '$value',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeEffectivenessSection(FusionResult result) {
    final brightness = Theme.of(context).brightness;
    final results = TypeEffectivenessChart.getDefenderChart(result.types);
    final groups = <double, List<TypeEffectResult>>{};
    for (final r in results) {
      groups.putIfAbsent(r.multiplier, () => []).add(r);
    }

    final sections = <Widget>[];

    for (final multiplier in TypeEffectiveness.multiplierOrder) {
      final items = groups[multiplier];
      if (items == null || items.isEmpty) continue;

      final label = _groupLabel(multiplier);
      final color = _getMultiplierColor(multiplier, brightness);

      sections.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGroupHeader(multiplier, label, color, items.length),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    items
                        .map<Widget>(
                          (item) => _buildResultChip(item, brightness),
                        )
                        .toList(),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '属性克制关系',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...sections,
          ],
        ),
      ),
    );
  }

  String _groupLabel(double multiplier) {
    return TypeEffectiveness.multiplierGroupLabel(multiplier);
  }

  Color _getMultiplierColor(double multiplier, Brightness brightness) {
    return TypeEffectiveness.getMultiplierColor(multiplier, brightness);
  }

  Color _getCardColor(
    Color typeColor,
    double multiplier,
    Brightness brightness,
  ) {
    return TypeEffectiveness.getTypeCardColor(
        typeColor, multiplier, brightness);
  }

  String _multiplierToString(double multiplier) {
    return TypeEffectiveness.multiplierToString(multiplier);
  }

  Widget _buildGroupHeader(double multiplier,
      String label,
      Color color,
      int count,) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '×${_multiplierToString(multiplier)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$count种属性',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildResultChip(TypeEffectResult result, Brightness brightness) {
    final typeColor = PokemonTypeColors.getTypeColor(result.type);
    final multiplierColor = _getMultiplierColor(result.multiplier, brightness);
    final cardColor = _getCardColor(typeColor, result.multiplier, brightness);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: multiplierColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: typeColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            result.type,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _showPokemonPicker(bool isHead) {
    final provider = context.read<FusionProvider>();
    final TextEditingController searchController = TextEditingController();
    List<FusionPokemonModel> searchResults = provider.allPokemonList;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        children: [
                          Text(
                            isHead ? '选择头部宝可梦' : '选择身体宝可梦',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: '搜索名称或编号',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        onChanged: (query) {
                          setSheetState(() {
                            searchResults = provider.searchPokemon(query);
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child:
                          searchResults.isEmpty
                              ? const Center(child: Text('未找到匹配的宝可梦'))
                              : ListView.builder(
                                controller: scrollController,
                                itemCount: searchResults.length,
                                itemBuilder: (context, index) {
                                  final pokemon = searchResults[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                      leading: PokemonSpriteIcon(
                                        iconPosition: pokemon.iconPosition,
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
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                            '${pokemon.nameJp} / ${pokemon.nameEn}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 4,
                                            runSpacing: 4,
                                            children:
                                                pokemon.types
                                                    .map(
                                                      (t) => TypeChip(type: t),
                                                    )
                                                    .toList(),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        if (isHead) {
                                          provider.selectHeadPokemon(pokemon);
                                        } else {
                                          provider.selectBodyPokemon(pokemon);
                                        }
                                        Navigator.pop(ctx);
                                      },
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
