import 'package:flutter/material.dart';

class SelectableChip extends StatelessWidget {
  final String text;
  final bool selected;
  final Color bgColor;
  final VoidCallback onTap;

  const SelectableChip({
    super.key,
    required this.text,
    required this.selected,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: selected ? 12 : 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow:
                selected
                    ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : [],
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
