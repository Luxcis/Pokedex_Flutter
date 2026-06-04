import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/home/home.dart';
import 'package:pokedex/providers/ability_provider.dart';
import 'package:pokedex/providers/fusion_provider.dart';
import 'package:pokedex/providers/move_provider.dart';
import 'package:pokedex/providers/pokemon_provider.dart';
import 'package:pokedex/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget createTestApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => PokemonProvider()),
      ChangeNotifierProvider(create: (_) => AbilityProvider()),
      ChangeNotifierProvider(create: (_) => MoveProvider()),
      ChangeNotifierProvider(create: (_) => FusionProvider()),
    ],
    child: const MaterialApp(home: HomePage()),
  );
}

void main() {
  testWidgets('Navigation tabs are present', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(createTestApp());
    await tester.pump();

    expect(find.text('图鉴'), findsOneWidget);
    expect(find.text('特性'), findsOneWidget);
    expect(find.text('招式'), findsOneWidget);
    expect(find.text('克制'), findsOneWidget);
    expect(find.text('融合'), findsOneWidget);
  });
}
