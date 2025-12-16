import 'dart:developer';

import 'package:flutter/material.dart';

class PokemonPage extends StatefulWidget {
  const PokemonPage({super.key});

  @override
  State createState() => _PokemonPageState();
}

class _PokemonPageState extends State<PokemonPage> {
  final TextEditingController _searchController = TextEditingController();

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
          // 为搜索框提供水平内边距
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '搜索',
              // 调整文本输入区域的内边距
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none, // 移除边框
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none, // 移除聚焦时的边框
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none, // 移除启用时的边框
              ),
              prefixIcon: Icon(Icons.search, color: Colors.grey), // 添加搜索图标
            ),
            onChanged: (text) {
              // 搜索文本改变时的回调
              log('搜索文本: $text');
            },
            onSubmitted: (text) {
              // 用户提交搜索时的回调
              log('提交搜索: $text');
            },
          ),
        ),
        actions: [],
      ),
    );
  }
}
