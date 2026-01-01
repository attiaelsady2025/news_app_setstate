import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:news_app/list_state/news_list/news_list_stat.dart';
import 'package:news_app/data/models/news_model.dart';
import '../widgets/news_card.dart';
import 'news_detail_screen.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  final _searchController = TextEditingController();
  final _newsListService = NewsListService();

  late List<NewsModel> _newsList = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNews('Egypt');
  }

  Future<void> _fetchNews(String searchedItem) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final newsResponse = await _newsListService.getNewsFromApi(
        searchedItem: searchedItem,
      );

      setState(() {
        _newsList = newsResponse;
        _isLoading = false;
        _searchController.clear();
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to fetch news. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Top News'),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hint: Text(
                    'Type to search..',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  suffix: IconButton(
                    icon: const Icon(Icons.search),
                    iconSize: 32,
                    onPressed: () {
                      if (_searchController.text.isNotEmpty) {
                        _fetchNews(_searchController.text);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_newsList.isEmpty) {
      return const Center(
        child: Text(
          'No news available. Tap the search button to fetch articles.',
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: _newsList.length,
      itemBuilder: (context, index) {
        return NewsCard(
          id: _newsList[index].id,
          title: _newsList[index].title,
          description: _newsList[index].description,
          imageUrl: _newsList[index].imageUrl,
          source: _newsList[index].source,
          publishedAt: DateTime.parse(_newsList[index].publishedAt),
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 400),
                pageBuilder: (_, __, ___) =>
                    NewsDetailScreen(article: _newsList[index]),
                transitionsBuilder: (_, anim, __, child) =>
                    FadeTransition(opacity: anim, child: child),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
