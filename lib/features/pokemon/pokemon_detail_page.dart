import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokedex/features/ability/ability_detail_page.dart';
import 'package:pokedex/features/move/move_detail_page.dart';
import 'package:pokedex/models/pokemon_detail_model.dart';
import 'package:pokedex/providers/ability_provider.dart';
import 'package:pokedex/providers/move_provider.dart';
import 'package:pokedex/widgets/type_chip.dart';
import 'package:provider/provider.dart';

Color _getStatColor(double value) {
  if (value >= 150) return const Color(0xFF4CAF50);
  if (value >= 100) return const Color(0xFF8BC34A);
  if (value >= 70) return const Color(0xFFFFC107);
  if (value >= 40) return const Color(0xFFFF9800);
  return const Color(0xFFF44336);
}

class PokemonDetailPage extends StatefulWidget {
  final String pokemonName;
  final String pokemonIndex;

  const PokemonDetailPage({
    super.key,
    required this.pokemonIndex,
    required this.pokemonName,
  });

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage>
    with TickerProviderStateMixin {
  PokemonDetailModel? _detail;
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedFormIndex = 0;
  TabController? _formTabController;
  bool _isProfileExpanded = false;
  final Set<String> _expandedGenerations = {};

  String get _jsonPath =>
      'assets/data/pokemon/${widget.pokemonIndex}-${widget.pokemonName}.json';

  PokemonFormModel get _currentForm => _detail!.forms[_selectedFormIndex];

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
      final jsonString = await rootBundle.loadString(_jsonPath);
      final Map<String, dynamic> json = jsonDecode(jsonString);
      _detail = PokemonDetailModel.fromJson(json);

      if (!mounted) return;

      if (_detail!.hasMultipleForms) {
        _formTabController = TabController(
          length: _detail!.forms.length,
          vsync: this,
        );
        _formTabController!.addListener(() {
          if (!_formTabController!.indexIsChanging) {
            setState(() {
              _selectedFormIndex = _formTabController!.index;
            });
          }
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      log('加载宝可梦详情失败: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = '数据加载失败，请重试';
      });
    }
  }

  @override
  void dispose() {
    _formTabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(_detail?.name ?? widget.pokemonName),
        bottom:
            _detail != null && _detail!.hasMultipleForms
                ? TabBar(
                  controller: _formTabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: colorScheme.onSurface,
                  unselectedLabelColor: colorScheme.onSurfaceVariant,
                  indicatorColor: colorScheme.primary,
                  tabs: _detail!.forms.map((f) => Tab(text: f.name)).toList(),
                )
                : null,
      ),
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
            Text(_errorMessage!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadDetail, child: const Text('重试')),
          ],
        ),
      );
    }

    if (_detail == null) {
      return const Center(child: Text('暂无数据'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMainImageSection(),
          _buildBasicInfoSection(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),
          _buildAbilitiesSection(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),
          _buildProfileSection(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),
          _buildStatsSection(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),
          _buildEvolutionSection(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),
          _buildHomeImagesSection(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),
          _buildFlavorTextSection(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),
          _buildLearnedMovesSection(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),
          _buildMachineMovesSection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMainImageSection() {
    final form = _currentForm;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Image.asset(
          'assets/data/images/official/${form.image}',
          height: 200,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              width: 200,
              color: Colors.grey[200],
              child: const Icon(
                Icons.catching_pokemon,
                size: 64,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    final form = _currentForm;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: form.types.map((t) => TypeChip(type: t)).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                form.genus,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            _buildCardCell('英文名', _detail!.nameEn),
            _buildCardCell('日文名', _detail!.nameJp),
          ),
          _buildInfoCard(
            _buildCardCell('身高', form.height),
            _buildCardCell('体重', form.weight),
          ),
          _buildInfoCard(
            _buildCardCell('体型', form.shape),
            _buildCardCell(
              '100级经验值',
              '${form.experience.number}（${form.experience.speed}）',
            ),
          ),
          _buildInfoCard(
            _buildCardCell('蛋群', form.eggGroups.join(' / ')),
            _buildCardCell('图鉴颜色', form.color),
          ),
          _buildInfoCard(
            _buildCardCell(
              '捕获率',
              '${form.catchRate.number}（${form.catchRate.rate}）',
            ),
            _buildCardCell(
              '性别比例',
              '♂${form.genderRate.male} / ♀${form.genderRate.female}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Widget left, Widget right) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(padding: const EdgeInsets.all(12), child: left),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(padding: const EdgeInsets.all(12), child: right),
          ),
        ),
      ],
    );
  }

  Widget _buildCardCell(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAbilitiesSection() {
    final abilities = _currentForm.ability;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('特性'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                abilities.map((a) {
                  return InkWell(
                    onTap: () {
                      final abilityProvider = context.read<AbilityProvider>();
                      final abilityIndex = abilityProvider.getAbilityIndex(
                        a.name,
                      );
                      if (abilityIndex != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => AbilityDetailPage(
                                  abilityIndex: abilityIndex,
                                  abilityName: a.name,
                                ),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              a.name,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          if (a.isHidden)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '隐藏',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.purple[800],
                                ),
                              ),
                            ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection() {
    final profile = _detail!.profile;
    const maxLength = 150;
    final isLong = profile.length > maxLength;
    final shortText = '${profile.substring(0, maxLength)}...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('简介'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AnimatedCrossFade(
            firstChild: Text(
              isLong ? shortText : profile,
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
            secondChild: Text(
              profile,
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
            crossFadeState:
                _isProfileExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ),
        if (isLong)
          GestureDetector(
            onTap: () {
              setState(() {
                _isProfileExpanded = !_isProfileExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Text(
                _isProfileExpanded ? '收起' : '展开',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatsSection() {
    final statsList = _detail!.stats;
    if (statsList.isEmpty) return const SizedBox.shrink();

    if (statsList.length > 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('种族值'),
          _StatsTabView(statsList: statsList),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('种族值'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildStatsDataView(statsList.first.data),
        ),
      ],
    );
  }

  Widget _buildStatsDataView(PokemonStatsDataModel data) {
    final statItems = data.items;
    final maxStat = 255.0;
    return Column(
      children:
          statItems.map((item) {
            final value = double.tryParse(item.value) ?? 0;
            final ratio = (value / maxStat).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(
                      item.label,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 36,
                    child: Text(
                      item.value,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getStatColor(value),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildEvolutionSection() {
    final chains = _detail!.evolutionChains;
    if (chains.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('进化链'),
        ...chains.map((chain) => _buildEvolutionChain(chain)),
      ],
    );
  }

  Widget _buildEvolutionChain(List<PokemonEvolutionNodeModel> chain) {
    const nodeWidth = 90.0;
    const arrowWidth = 56.0;
    final totalWidth =
        chain.length * nodeWidth + (chain.length - 1) * arrowWidth;

    return LayoutBuilder(
      builder: (context, constraints) {
        final nodes = _buildEvolutionNodes(chain);

        if (totalWidth <= constraints.maxWidth) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Row(mainAxisSize: MainAxisSize.min, children: nodes),
            ),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: nodes),
        );
      },
    );
  }

  List<Widget> _buildEvolutionNodes(List<PokemonEvolutionNodeModel> chain) {
    final nodes = <Widget>[];
    for (int i = 0; i < chain.length; i++) {
      if (i > 0) {
        nodes.add(_buildEvolutionArrow(chain[i]));
      }
      nodes.add(_buildEvolutionNode(chain[i]));
    }
    return nodes;
  }

  Widget _buildEvolutionArrow(PokemonEvolutionNodeModel node) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.arrow_forward, size: 20, color: Colors.grey),
          if (node.text != null && node.text!.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxWidth: 80),
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                node.text!,
                style: const TextStyle(fontSize: 9, color: Colors.grey),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEvolutionNode(PokemonEvolutionNodeModel node) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(6),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 64,
              height: 64,
              child: Image.asset(
                'assets/data/images/dream/${node.image}',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.catching_pokemon,
                    size: 32,
                    color: Colors.grey,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            node.name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            node.stage,
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHomeImagesSection() {
    final images = _detail!.homeImages;
    if (images.isEmpty) return const SizedBox.shrink();

    final normalImages = images.where((img) => img.image.isNotEmpty).toList();
    final shinyImages = images.where((img) => img.shiny.isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('形象'),
        if (normalImages.isNotEmpty) _buildHomeImageRow(normalImages, false),
        if (shinyImages.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildHomeImageRow(shinyImages, true),
        ],
      ],
    );
  }

  Widget _buildHomeImageRow(List<PokemonHomeImageModel> items, bool isShiny) {
    const itemWidth = 80.0;
    final totalWidth = items.length * itemWidth;

    return LayoutBuilder(
      builder: (context, constraints) {
        final children =
            items.map((img) {
              return _buildHomeImageItem(
                isShiny ? img.shiny : img.image,
                img.name,
                isShiny,
              );
            }).toList();

        if (totalWidth <= constraints.maxWidth) {
          return SizedBox(
            height: 100,
            child: Center(
              child: Row(mainAxisSize: MainAxisSize.min, children: children),
            ),
          );
        }

        return SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: children,
          ),
        );
      },
    );
  }

  Widget _buildHomeImageItem(String imageName, String label, bool isShiny) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 72,
              height: 72,
              child: Image.asset(
                'assets/data/images/home/$imageName',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.catching_pokemon,
                    size: 28,
                    color: Colors.grey,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            width: 72,
            child: Text(
              isShiny ? '$label✨' : label,
              style: const TextStyle(fontSize: 9, color: Colors.grey),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlavorTextSection() {
    final flavorTexts = _detail!.flavorTexts;
    if (flavorTexts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('图鉴介绍'),
        ...flavorTexts.map((group) {
          final isExpanded = _expandedGenerations.contains(group.name);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Card(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedGenerations.remove(group.name);
                        } else {
                          _expandedGenerations.add(group.name);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              group.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child:
                        isExpanded
                            ? Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                              child: Column(
                                children:
                                    group.versions.map((v) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 4,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 88,
                                              child: Text(
                                                v.name,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                v.text,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                              ),
                            )
                            : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLearnedMovesSection() {
    final learned = _detail!.moves.learned;
    if (learned.isEmpty) return const SizedBox.shrink();

    if (learned.length > 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('招式列表（升级）'),
          _MoveTabView(moveGroups: learned),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('招式列表（升级）'),
        _buildMoveTable(learned.first.data),
      ],
    );
  }

  Widget _buildMachineMovesSection() {
    final machine = _detail!.moves.machine;
    if (machine.isEmpty) return const SizedBox.shrink();

    if (machine.length > 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('招式列表（招式学习器）'),
          _MoveTabView(moveGroups: machine),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('招式列表（招式学习器）'),
        _buildMoveTable(machine.first.data),
      ],
    );
  }

  static const _moveColumns = <DataColumn>[
    DataColumn(
      label: SizedBox(
        width: 36,
        child: Text(
          '等级',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    ),
    DataColumn(
      label: SizedBox(
        width: 64,
        child: Text(
          '招式',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    ),
    DataColumn(
      label: SizedBox(
        width: 36,
        child: Text(
          '属性',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    ),
    DataColumn(
      label: SizedBox(
        width: 32,
        child: Text(
          '分类',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    ),
    DataColumn(
      label: SizedBox(
        width: 32,
        child: Text(
          '威力',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    ),
    DataColumn(
      label: SizedBox(
        width: 32,
        child: Text(
          '命中',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    ),
    DataColumn(
      label: SizedBox(
        width: 28,
        child: Text(
          'PP',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    ),
  ];

  Widget _buildMoveTable(List<PokemonMoveDataModel> moves) {
    const tableWidth = 292.0;
    final table = DataTable(
      columnSpacing: 0,
      dataRowMinHeight: 32,
      dataRowMaxHeight: 40,
      headingRowHeight: 36,
      columns: _moveColumns,
      rows:
          moves.map((move) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    move.levelLearnedAt ?? '—',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                DataCell(
                  InkWell(
                    onTap: () => _onMoveTap(move.name),
                    child: Text(
                      move.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                DataCell(TypeChipSmall(type: move.type)),
                DataCell(
                  Text(move.category, style: const TextStyle(fontSize: 12)),
                ),
                DataCell(
                  Text(
                    move.power.isNotEmpty ? move.power : '—',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                DataCell(
                  Text(
                    move.accuracy.isNotEmpty ? move.accuracy : '—',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                DataCell(Text(move.pp, style: const TextStyle(fontSize: 12))),
              ],
            );
          }).toList(),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (tableWidth <= constraints.maxWidth) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: constraints.maxWidth,
              child: Center(child: table),
            ),
          );
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: table,
        );
      },
    );
  }

  void _onMoveTap(String moveName) {
    final moveProvider = context.read<MoveProvider>();
    final moveIndex = moveProvider.getMoveIndex(moveName);
    if (moveIndex != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => MoveDetailPage(moveIndex: moveIndex, moveName: moveName),
        ),
      );
    }
  }

}

class _StatsTabView extends StatefulWidget {
  final List<PokemonStatsGroupModel> statsList;

  const _StatsTabView({required this.statsList});

  @override
  State<_StatsTabView> createState() => _StatsTabViewState();
}

class _StatsTabViewState extends State<_StatsTabView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _tabController = TabController(
      length: widget.statsList.length,
      vsync: this,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: widget.statsList.map((s) => Tab(text: s.form)).toList(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _buildStatsDataView(widget.statsList[_currentIndex].data),
        ),
      ],
    );
  }

  Widget _buildStatsDataView(PokemonStatsDataModel data) {
    final statItems = data.items;
    const maxStat = 255.0;
    return Column(
      children:
          statItems.map((item) {
            final value = double.tryParse(item.value) ?? 0;
            final ratio = (value / maxStat).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(
                      item.label,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 36,
                    child: Text(
                      item.value,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getStatColor(value),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

}

class _MoveTabView extends StatefulWidget {
  final List<PokemonMoveGroupModel> moveGroups;

  const _MoveTabView({required this.moveGroups});

  @override
  State<_MoveTabView> createState() => _MoveTabViewState();
}

class _MoveTabViewState extends State<_MoveTabView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _tabController = TabController(
      length: widget.moveGroups.length,
      vsync: this,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const tableWidth = 292.0;
    final table = DataTable(
      columnSpacing: 0,
      dataRowMinHeight: 32,
      dataRowMaxHeight: 40,
      headingRowHeight: 36,
      columns: _PokemonDetailPageState._moveColumns,
      rows:
          widget.moveGroups[_currentIndex].data.map((move) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    move.levelLearnedAt ?? '—',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                DataCell(
                  InkWell(
                    onTap: () {
                      final moveProvider = context.read<MoveProvider>();
                      final moveIndex = moveProvider.getMoveIndex(move.name);
                      if (moveIndex != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => MoveDetailPage(
                                  moveIndex: moveIndex,
                                  moveName: move.name,
                                ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      move.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                DataCell(TypeChipSmall(type: move.type)),
                DataCell(
                  Text(move.category, style: const TextStyle(fontSize: 12)),
                ),
                DataCell(
                  Text(
                    move.power.isNotEmpty ? move.power : '—',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                DataCell(
                  Text(
                    move.accuracy.isNotEmpty ? move.accuracy : '—',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                DataCell(Text(move.pp, style: const TextStyle(fontSize: 12))),
              ],
            );
          }).toList(),
    );

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: widget.moveGroups.map((g) => Tab(text: g.form)).toList(),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            if (tableWidth <= constraints.maxWidth) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: constraints.maxWidth,
                  child: Center(child: table),
                ),
              );
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: table,
            );
          },
        ),
      ],
    );
  }

}
