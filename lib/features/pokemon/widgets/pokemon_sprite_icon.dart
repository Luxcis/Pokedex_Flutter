import 'package:flutter/material.dart';

class PokemonSpriteIcon extends StatelessWidget {
  static final _positionRegex = RegExp(r'(-?\d+)px');

  final String iconPosition;
  final double size;

  const PokemonSpriteIcon({
    super.key,
    required this.iconPosition,
    this.size = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    final positions = _parseIconPosition(iconPosition);
    final offsetX = positions[0];
    final offsetY = positions[1];
    const double scale = 0.5;

    return SizedBox(
      width: size,
      height: size,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          child: Transform.translate(
            offset: Offset(offsetX, offsetY),
            child: Transform.scale(
              alignment: Alignment.topLeft,
              scale: scale,
              child: Image.asset(
                'assets/data/images/normal.webp',
                alignment: Alignment.topLeft,
                fit: BoxFit.none,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<double> _parseIconPosition(String position) {
    // 解析类似 "-1176px -280px" 的字符串
    final matches = _positionRegex.allMatches(position);

    if (matches.length >= 2) {
      final x = double.tryParse(matches.elementAt(0).group(1) ?? '0') ?? 0.0;
      final y = double.tryParse(matches.elementAt(1).group(1) ?? '0') ?? 0.0;
      return [x, y];
    }

    return [0.0, 0.0];
  }
}
