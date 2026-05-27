import 'package:flutter/material.dart';
import 'package:pokedex/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeDropdownItems = [
      DropdownMenuItem(value: ThemeMode.light, child: Text('浅色')),
      DropdownMenuItem(value: ThemeMode.dark, child: Text('深色')),
      DropdownMenuItem(value: ThemeMode.system, child: Text('跟随系统')),
    ];
    final themeSettingsItem = _SettingItem(
      title: '应用主题',
      icon: Icons.brightness_4,
      editor: DropdownButton(
        value: themeProvider.themeMode,
        items: themeDropdownItems,
        onChanged: (ThemeMode? newTheme) {
          if (newTheme == null) return;
          themeProvider.setThemeMode(newTheme);
        },
      ),
      onTap: null,
      description: null,
    );
    return Scaffold(
      appBar: AppBar(title: Text('设置')),
      body: ListView(children: [themeSettingsItem]),
    );
  }
}

class _SettingItem extends StatelessWidget {
  const _SettingItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.editor,
    this.description,
  });

  final String title;
  final String? description;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? editor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ListTile(
        title: Text(title, style: TextStyle(fontSize: 18)),
        subtitle: description != null ? Text(description!) : null,
        leading: Icon(icon),
        trailing: editor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
