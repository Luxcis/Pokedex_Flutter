import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {
  final VoidCallback onTap;

  const FilterButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: onTap,
      icon: Icon(Icons.filter_list, color: colorScheme.onSurfaceVariant),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    );
  }
}
