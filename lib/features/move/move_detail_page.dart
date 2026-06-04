import 'package:flutter/material.dart';
import 'package:pokedex/features/pokemon/pokemon_detail_page.dart';
import 'package:pokedex/features/pokemon/widgets/pokemon_sprite_icon.dart';
import 'package:pokedex/models/move_detail_model.dart';
import 'package:pokedex/providers/move_provider.dart';
import 'package:pokedex/widgets/category_chip.dart';
import 'package:pokedex/widgets/type_chip.dart';
import 'package:provider/provider.dart';

class MoveDetailPage extends StatefulWidget {
  final String moveIndex;
  final String moveName;

  const MoveDetailPage({
    super.key,
    required this.moveIndex,
    required this.moveName,
  });

  @override
  State createState() => _MoveDetailPageState();
}

class _MoveDetailPageState extends State<MoveDetailPage> {
  MoveDetailModel? _detail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = context.read<MoveProvider>();
      final detail = await provider.loadMoveDetail(
        widget.moveIndex,
        widget.moveName,
      );
      if (mounted) {
        setState(() {
          _detail = detail;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '加载详情失败: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(scrolledUnderElevation: 0, title: Text(widget.moveName)),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadDetail, child: const Text('重试')),
          ],
        ),
      );
    }

    final detail = _detail!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(detail),
          const SizedBox(height: 24),
          _buildEffectSection(detail),
          const SizedBox(height: 24),
          _buildRangeSection(detail),
          const SizedBox(height: 24),
          _buildInfoSection(detail),
          const SizedBox(height: 24),
          _buildPokemonListSection(detail),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(MoveDetailModel detail) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          detail.name,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${detail.nameJp}  ${detail.nameEn}',
          style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        _buildInfoRow('引入世代', detail.generation),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            TypeChip(type: detail.type),
            CategoryChip(category: detail.category),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatItem('威力', detail.power),
            const SizedBox(width: 24),
            _buildStatItem('命中', detail.accuracy),
            const SizedBox(width: 24),
            _buildStatItem('PP', detail.pp),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            detail.text,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          value.isNotEmpty ? value : '—',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEffectSection(MoveDetailModel detail) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('效果'),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            detail.effect.isNotEmpty ? detail.effect.trim() : '暂无效果描述',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRangeSection(MoveDetailModel detail) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('范围'),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            detail.range.isNotEmpty ? detail.range : '暂无范围信息',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(MoveDetailModel detail) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('基本信息'),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                detail.info
                    .map(
                      (info) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontSize: 13)),
                            Expanded(
                              child: Text(
                                info,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPokemonListSection(MoveDetailModel detail) {
    final pokemon = detail.pokemon;
    final hasAny =
        pokemon.level.isNotEmpty ||
        pokemon.machine.isNotEmpty ||
        pokemon.egg.isNotEmpty ||
        pokemon.tutor.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('可以学会该招式的宝可梦'),
        const SizedBox(height: 8),
        if (!hasAny)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '暂无关联宝可梦',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          ..._buildPokemonGroups(pokemon),
      ],
    );
  }

  List<Widget> _buildPokemonGroups(MovePokemonGroups pokemon) {
    final groups = <Widget>[];

    if (pokemon.level.isNotEmpty) {
      groups.add(_buildPokemonGroup('升级习得', pokemon.level));
    }
    if (pokemon.machine.isNotEmpty) {
      groups.add(_buildPokemonGroup('招式学习器习得', pokemon.machine));
    }
    if (pokemon.egg.isNotEmpty) {
      groups.add(_buildPokemonGroup('遗传习得', pokemon.egg));
    }
    if (pokemon.tutor.isNotEmpty) {
      groups.add(_buildPokemonGroup('教授招式习得', pokemon.tutor));
    }

    return groups;
  }

  Widget _buildPokemonGroup(String title, List<MovePokemon> pokemonList) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...pokemonList.map((p) => _buildPokemonCard(p)),
        ],
      ),
    );
  }

  Widget _buildPokemonCard(MovePokemon pokemon) {
    return FutureBuilder(
      future: Future.wait([
        context.read<MoveProvider>().getPokemonIconPosition(pokemon.index),
        context.read<MoveProvider>().getPokemonTypes(pokemon.index),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        String? iconPos;
        List<String> types = [];

        if (snapshot.hasData) {
          iconPos = snapshot.data![0] as String?;
          types = List<String>.from(snapshot.data![1] as List<dynamic>);
        }

        return InkWell(
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
          borderRadius: BorderRadius.circular(12),
          child: Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  if (iconPos != null && iconPos.isNotEmpty)
                    PokemonSpriteIcon(iconPosition: iconPos, size: 56)
                  else
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: Icon(
                        Icons.catching_pokemon,
                        size: 32,
                        color: Colors.grey[400],
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pokemon.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (types.isNotEmpty)
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children:
                                types.map((t) => TypeChip(type: t)).toList(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '#${pokemon.index}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
