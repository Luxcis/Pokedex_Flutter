import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pokedex/features/pokemon/widgets/pokemon_sprite_icon.dart';
import 'package:pokedex/models/pokemon_model.dart';
import 'package:pokedex/providers/pokemon_provider.dart';
import 'package:pokedex/utils/pokemon_type_colors.dart';
import 'package:provider/provider.dart';

class PokemonPage extends StatefulWidget {
  const PokemonPage({super.key});

  @override
  State createState() => _PokemonPageState();
}

class _PokemonPageState extends State<PokemonPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 加载宝可梦数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PokemonProvider>().loadPokemonData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '搜索',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
            ),
            onChanged: (text) {
              // 实时搜索
              context.read<PokemonProvider>().searchPokemon(text);
            },
            onSubmitted: (text) {
              log('提交搜索: $text');
            },
          ),
        ),
        actions: const [],
      ),
      body: Consumer<PokemonProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadPokemonData(),
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          if (provider.filteredPokemonList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.searchQuery.isEmpty
                        ? '暂无宝可梦数据'
                        : '未找到匹配的宝可梦',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.filteredPokemonList.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final pokemon = provider.filteredPokemonList[index];
              return _buildPokemonCard(pokemon);
            },
          );
        },
      ),
    );
  }

  Widget _buildPokemonCard(PokemonModel pokemon) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: PokemonSpriteIcon(
          iconPosition: pokemon.meta.iconPosition,
          size: 56,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                pokemon.name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '#${pokemon.index}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${pokemon.nameJp} / ${pokemon.nameEn}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: pokemon.types
                  .map((type) => _buildTypeChip(type))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: PokemonTypeColors.getTypeColor(type),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
