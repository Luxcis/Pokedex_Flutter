import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/features/home/home.dart';
import 'package:pokedex/providers/ability_provider.dart';
import 'package:pokedex/providers/fusion_provider.dart';
import 'package:pokedex/providers/move_provider.dart';
import 'package:pokedex/providers/pokemon_provider.dart';
import 'package:pokedex/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _seedColor = Colors.deepPurple;

  ColorScheme _buildColorScheme(ColorScheme? dynamicScheme,
      Brightness brightness,) {
    return dynamicScheme ??
        ColorScheme.fromSeed(seedColor: _seedColor, brightness: brightness);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final lightScheme = _buildColorScheme(lightDynamic, Brightness.light);
        final darkScheme = _buildColorScheme(darkDynamic, Brightness.dark);
        return MaterialApp(
          title: 'Template',
          theme: ThemeData(
            colorScheme: lightScheme,
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: lightScheme.surface,
            ),
            appBarTheme: AppBarThemeData(
              backgroundColor: lightScheme.surface,
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: darkScheme,
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: darkScheme.surface,
            ),
            appBarTheme: AppBarThemeData(
              backgroundColor: darkScheme.surface,
            ),
          ),
          themeMode: themeProvider.themeMode,
          home: const HomePage(),
        );
      },
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final entry = MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => PokemonProvider()),
      ChangeNotifierProvider(create: (_) => AbilityProvider()),
      ChangeNotifierProvider(create: (_) => MoveProvider()),
      ChangeNotifierProvider(create: (_) => FusionProvider()),
    ],
    child: const MyApp(),
  );
  runApp(entry);
}
