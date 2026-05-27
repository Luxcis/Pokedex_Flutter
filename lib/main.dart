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
  @override
  Widget build(BuildContext context) {
    const defaultColorTheme = Colors.deepPurple;
    final themeProvider = Provider.of<ThemeProvider>(context);
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          title: 'Template',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: defaultColorTheme,
              brightness: Brightness.light,
            ),
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor:
                  ColorScheme.fromSeed(
                    seedColor: defaultColorTheme,
                    brightness: Brightness.light,
                  ).surface,
            ),
            appBarTheme: AppBarThemeData(
              backgroundColor:
                  ColorScheme.fromSeed(
                    seedColor: defaultColorTheme,
                    brightness: Brightness.light,
                  ).surface,
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: defaultColorTheme,
              brightness: Brightness.dark,
            ),
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor:
                  ColorScheme.fromSeed(
                    seedColor: defaultColorTheme,
                    brightness: Brightness.dark,
                  ).surface,
            ),
            appBarTheme: AppBarThemeData(
              backgroundColor:
                  ColorScheme.fromSeed(
                    seedColor: defaultColorTheme,
                    brightness: Brightness.light,
                  ).surface,
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
