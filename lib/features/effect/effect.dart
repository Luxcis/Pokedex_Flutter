import 'package:flutter/material.dart';
import 'package:pokedex/features/settings/settings.dart';
import 'package:pokedex/utils/pokemon_type_colors.dart';
import 'package:pokedex/utils/type_effectiveness.dart';

enum EffectMode { defense, offense }

class EffectPage extends StatefulWidget {
  const EffectPage({super.key});

  @override
  State createState() => _EffectPageState();
}

class _EffectPageState extends State<EffectPage> {
  EffectMode _mode = EffectMode.defense;
  String? _defendType1;
  String? _defendType2;
  String? _attackType;

  List<TypeEffectResult> get _results {
    if (_mode == EffectMode.defense) {
      if (_defendType1 == null) return [];
      final types = <String>[_defendType1!];
      if (_defendType2 != null) types.add(_defendType2!);
      return TypeEffectivenessChart.getDefenderChart(types);
    } else {
      if (_attackType == null) return [];
      return TypeEffectivenessChart.getAttackerChart(_attackType!);
    }
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

  void _switchMode(EffectMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
    });
  }

  Map<double, List<TypeEffectResult>> get _groupedResults {
    final groups = <double, List<TypeEffectResult>>{};
    for (final result in _results) {
      groups.putIfAbsent(result.multiplier, () => []).add(result);
    }
    return groups;
  }

  String _groupLabel(double multiplier) {
    return TypeEffectiveness.multiplierGroupLabel(multiplier);
  }

  void _onDefendType1Changed(String? value) {
    setState(() {
      _defendType1 = value;
      if (_defendType2 == value) {
        _defendType2 = null;
      }
    });
  }

  void _onDefendType2Changed(String? value) {
    setState(() {
      _defendType2 = value;
    });
  }

  void _onAttackTypeChanged(String? value) {
    setState(() {
      _attackType = value;
    });
  }

  List<String> _getAvailableTypes(String? excludeType) {
    return TypeEffectivenessChart.selectableTypes
        .where((t) => t != excludeType)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colorScheme = Theme.of(context).colorScheme;
    final actions = [
      IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const SettingsPage()));
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('属性克制'), actions: actions),
      body: Column(
        children: [
          _buildModeSwitch(colorScheme),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_mode == EffectMode.defense)
                    _buildDefenseInputs(colorScheme, brightness)
                  else
                    _buildOffenseInputs(colorScheme, brightness),
                  const SizedBox(height: 20),
                  if (_results.isNotEmpty) ...[
                    _buildResultLegend(brightness),
                    const SizedBox(height: 12),
                    _buildGroupedResults(brightness),
                  ] else
                    _buildEmptyHint(colorScheme),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSwitch(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeTab(
              label: '防御模式',
              icon: Icons.shield,
              selected: _mode == EffectMode.defense,
              onTap: () => _switchMode(EffectMode.defense),
              colorScheme: colorScheme,
            ),
          ),
          Expanded(
            child: _buildModeTab(
              label: '进攻模式',
              icon: Icons.bolt,
              selected: _mode == EffectMode.offense,
              onTap: () => _switchMode(EffectMode.offense),
              colorScheme: colorScheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color:
                  selected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color:
                    selected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefenseInputs(ColorScheme colorScheme, Brightness brightness) {
    final availableFor1 = _getAvailableTypes(null);
    final availableFor2 =
        _defendType1 != null ? _getAvailableTypes(_defendType1) : <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择防御方属性（最多2个，复合计算）',
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTypeDropdown(
                value: _defendType1,
                items: availableFor1,
                hint: '选择属性 1',
                onChange: _onDefendType1Changed,
                typeColor:
                    _defendType1 != null
                        ? PokemonTypeColors.getTypeColor(_defendType1!)
                        : null,
                colorScheme: colorScheme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeDropdown(
                value: _defendType2,
                items: availableFor2,
                hint: _defendType1 != null ? '选择属性 2' : '请先选属性 1',
                onChange: _onDefendType2Changed,
                enabled: _defendType1 != null,
                typeColor:
                    _defendType2 != null
                        ? PokemonTypeColors.getTypeColor(_defendType2!)
                        : null,
                colorScheme: colorScheme,
              ),
            ),
          ],
        ),
        if (_defendType2 == null && _defendType1 != null) ...[
          const SizedBox(height: 8),
          Text(
            '支持选择1个或2个属性进行复合计算',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOffenseInputs(ColorScheme colorScheme, Brightness brightness) {
    final available = _getAvailableTypes(null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择进攻方属性',
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _buildTypeDropdown(
            value: _attackType,
            items: available,
            hint: '选择攻击属性',
            onChange: _onAttackTypeChanged,
            typeColor:
                _attackType != null
                    ? PokemonTypeColors.getTypeColor(_attackType!)
                    : null,
            colorScheme: colorScheme,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChange,
    Color? typeColor,
    bool enabled = true,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color:
            enabled
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.4),
              fontSize: 14,
            ),
          ),
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          items:
              items.map((type) {
                final color = PokemonTypeColors.getTypeColor(type);
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(type),
                    ],
                  ),
                );
              }).toList(),
          onChanged: enabled ? onChange : null,
        ),
      ),
    );
  }

  Widget _buildResultLegend(Brightness brightness) {
    return Text(
      _mode == EffectMode.defense ? '所有攻击属性对当前防御组合的倍率' : '当前攻击属性对所有防御属性的倍率',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildGroupedResults(Brightness brightness) {
    final groups = _groupedResults;
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

    return Column(children: sections);
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
            '×${TypeEffectiveness.multiplierToString(multiplier)}',
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

  Widget _buildEmptyHint(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            _mode == EffectMode.defense ? Icons.shield_outlined : Icons.bolt,
            size: 48,
            color: colorScheme.onSurface.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 12),
          Text(
            _mode == EffectMode.defense ? '请至少选择1个防御属性查看倍率' : '请选择进攻属性查看倍率',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
