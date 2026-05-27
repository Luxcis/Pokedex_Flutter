import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pokedex/features/ability/ability.dart';
import 'package:pokedex/features/effect/effect.dart';
import 'package:pokedex/features/fusion/fusion.dart';
import 'package:pokedex/features/move/move.dart';
import 'package:pokedex/features/pokemon/pokemon.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;
  bool _isTransitioning = false;
  double _pageOpacity = 1.0;

  static const _navAnimationMs = 200;
  static const _antiClickMs = 200;

  final List<_NavItemData> _navItems = const [
    _NavItemData(
      selectedIcon: Icon(PhosphorIconsFill.pawPrint),
      icon: Icon(PhosphorIconsBold.pawPrint),
      label: '图鉴',
    ),
    _NavItemData(
      selectedIcon: Icon(Icons.lightbulb),
      icon: Icon(Icons.lightbulb_outlined),
      label: '特性',
    ),
    _NavItemData(
      selectedIcon: Icon(Icons.front_hand),
      icon: Icon(Icons.front_hand_outlined),
      label: '招式',
    ),
    _NavItemData(
      selectedIcon: Icon(Icons.pentagon),
      icon: Icon(Icons.pentagon_outlined),
      label: '克制',
    ),
    _NavItemData(
      selectedIcon: Icon(PhosphorIconsBold.dna),
      icon: Icon(PhosphorIconsFill.dna),
      label: '融合',
    ),
  ];

  final List<Widget> _pages = const [
    PokemonPage(),
    AbilityPage(),
    MovePage(),
    EffectPage(),
    FusionPage(),
  ];

  void _onNavTap(int index) {
    if (_isTransitioning || index == currentPageIndex) return;
    _isTransitioning = true;

    setState(() {
      _pageOpacity = 0.0;
    });

    Future.delayed(const Duration(milliseconds: 130), () {
      if (!mounted) return;
      setState(() {
        currentPageIndex = index;
        _pageOpacity = 1.0;
      });
    });

    Future.delayed(const Duration(milliseconds: _antiClickMs), () {
      if (mounted) {
        _isTransitioning = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      bottomNavigationBar: _buildAnimatedNavBar(colorScheme),
      body: _buildPageContent(),
    );
  }

  Widget _buildPageContent() {
    return ClipRect(
      child: AnimatedOpacity(
        opacity: _pageOpacity,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeInOut,
        child: IndexedStack(index: currentPageIndex, children: _pages),
      ),
    );
  }

  Widget _buildAnimatedNavBar(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / _navItems.length;
          final indicatorWidth = itemWidth - 16;
          return SizedBox(
            height: 80,
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: _navAnimationMs),
                  curve: Curves.easeInOut,
                  left:
                      currentPageIndex * itemWidth +
                      (itemWidth - indicatorWidth) / 2,
                  top: 8,
                  child: Container(
                    width: indicatorWidth,
                    height: 62,
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                Row(
                  children: List.generate(_navItems.length, (index) {
                    final isSelected = currentPageIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onNavTap(index),
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconTheme(
                              data: IconThemeData(
                                color:
                                    isSelected
                                        ? colorScheme.onSecondaryContainer
                                        : colorScheme.onSurfaceVariant,
                                size: 24,
                              ),
                              child:
                                  isSelected
                                      ? _navItems[index].selectedIcon
                                      : _navItems[index].icon,
                            ),
                            AnimatedSize(
                              duration: const Duration(
                                milliseconds: _navAnimationMs,
                              ),
                              curve: Curves.easeInOut,
                              alignment: Alignment.topCenter,
                              child: SizedBox(
                                height: isSelected ? 24.0 : 0.0,
                                child: AnimatedOpacity(
                                  duration: const Duration(
                                    milliseconds: _navAnimationMs,
                                  ),
                                  curve: Curves.easeInOut,
                                  opacity: isSelected ? 1.0 : 0.0,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      _navItems[index].label,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            isSelected
                                                ? colorScheme
                                                    .onSecondaryContainer
                                                : colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NavItemData {
  final Icon selectedIcon;
  final Icon icon;
  final String label;

  const _NavItemData({
    required this.selectedIcon,
    required this.icon,
    required this.label,
  });
}
