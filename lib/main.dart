import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart';
import 'summary.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: ArticleView());
  }
}

class ArticleModel {
  Future<Summary> getRandomArticleSummary() async {
    final uri = Uri.https(
      'en.wikipedia.org',
      '/api/rest_v1/page/random/summary',
    );
    final response = await get(uri);
    if (response.statusCode != 200) {
      throw HttpException('Failed to update resource');
    }
    return Summary.fromJson(jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<List<Summary>> searchArticles(String query) async {
    final headers = {
      'User-Agent': 'WikipediaReader/1.0 (mksh2810/Wikipedia-Reader; support@example.com)'
    };
    final uri = Uri.https('en.wikipedia.org', '/w/api.php', {
      'action': 'query',
      'list': 'search',
      'srsearch': query,
      'format': 'json',
      'srwhat': 'text',
      'srlimit': '10',
      'origin': '*',
    });

    final response = await get(uri, headers: headers);
    if (response.statusCode != 200) {
      throw HttpException('Failed to search articles.');
    }

    final json = jsonDecode(response.body);
    final searchResults = (json['query']?['search'] as List<dynamic>?) ?? [];

    List<Summary> summaries = [];
    for (var result in searchResults) {
      try {
        final title = result['title'] as String;
        final summaryUri = Uri.https(
          'en.wikipedia.org',
          '/api/rest_v1/page/summary/$title',
        );
        final summaryResponse = await get(summaryUri, headers: headers);
        if (summaryResponse.statusCode == 200) {
          summaries.add(
            Summary.fromJson(
              jsonDecode(summaryResponse.body) as Map<String, Object?>,
            ),
          );
        }
      } catch (e) {
        print('Error fetching summary for result: $e');
      }
    }
    return summaries;
  }
}

class ArticleViewModel extends ChangeNotifier {
  final ArticleModel model;
  Summary? summary;
  Exception? error;
  bool isLoading = false;
  ArticleViewModel(this.model) {
    fetchArticle();
  }
  Future<void> fetchArticle() async {
    isLoading = true;
    notifyListeners();
    try {
      summary = await model.getRandomArticleSummary();
      print('Article loaded: ${summary?.titles.normalized}');
      error = null;
    } on HttpException catch (e) {
      print('Error loading article ${e.message}');
      error = e;
      summary = null;
    }
    isLoading = false;
    notifyListeners();
  }
  List<Summary> searchResults = [];
  bool isSearching = false;

  Future<void> searchArticles(String query) async {
    if (query.isEmpty) {
      searchResults = [];
      notifyListeners();
      return;
    }
    
    isSearching = true;
    notifyListeners();
    try {
      searchResults = await model.searchArticles(query);
      print('Search query: "$query", found ${searchResults.length} articles: ${searchResults.map((e) => e.titles.normalized).toList()}');
      error = null;
    } on HttpException catch (e) {
      print('Error searching articles: ${e.message}');
      error = e;
      searchResults = [];
    }
    isSearching = false;
    notifyListeners();
  }

  Future<void> selectArticle(Summary article) async {
    summary = article;
    searchResults = [];
    notifyListeners();
  }
}

class ArticleView extends StatefulWidget {
  const ArticleView({super.key});

  @override
  State<ArticleView> createState() => _ArticleViewState();
}

class _ArticleViewState extends State<ArticleView> {
  final ArticleViewModel viewModel = ArticleViewModel(ArticleModel());
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    viewModel.fetchArticle();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          backgroundColor: Colors.blue.shade200,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade200,
                  const Color.fromARGB(255, 187, 251, 211),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Let\'s explore\tWikipedia',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _searchController,
                      textAlignVertical: TextAlignVertical.center,
                      onSubmitted: (query) {
                        viewModel.searchArticles(query);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search articles...',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        prefixIcon: IconButton(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          constraints: const BoxConstraints(),
                          icon: Icon(Icons.search, color: Colors.grey.shade600),
                          onPressed: () {
                            viewModel.searchArticles(_searchController.text);
                          },
                        ),
                        suffixIcon: ListenableBuilder(
                          listenable: viewModel,
                          builder: (context, _) {
                            if (viewModel.isSearching) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Center(
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return ListenableBuilder(
                              listenable: _searchController,
                              builder: (context, _) {
                                if (_searchController.text.isNotEmpty) {
                                  return IconButton(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      viewModel.searchArticles('');
                                    },
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          // Show search results if any
          if (viewModel.searchResults.isNotEmpty) {
            return ListView.builder(
              itemCount: viewModel.searchResults.length,
              itemBuilder: (context, index) {
                final article = viewModel.searchResults[index];
                return ListTile(
                  leading: article.thumbnail != null
                      ? Image.network(article.thumbnail!.source)
                      : Icon(Icons.article),
                  title: Text(article.titles.normalized),
                  subtitle: Text(
                    article.description ?? article.extract,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    viewModel.selectArticle(article);
                  },
                );
              },
            );
          }

          // Original state handling
          return switch ((
            viewModel.isLoading,
            viewModel.summary,
            viewModel.error,
          )) {
            (true, _, _) => const Center(child: CircularProgressIndicator()),
            (_, _, final Exception e) => Center(child: Text('Error: $e')),
            (_, final summary?, _) => ArticlePage(
              summary: summary,
              nextArticleCallback: viewModel.fetchArticle,
            ),
            _ => const Center(child: Text('Something went wrong!')),
          };
        },
      ),
    );
  }
}

class ArticlePage extends StatelessWidget {
  const ArticlePage({
    super.key,
    required this.summary,
    required this.nextArticleCallback,
  });
  final Summary summary;
  final VoidCallback nextArticleCallback;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ArticleWidget(summary: summary),
          ElevatedButton(
            onPressed: nextArticleCallback,
            child: Text('Next random article'),
          ),
        ],
      ),
    );
  }
}

class ArticleWidget extends StatelessWidget {
  const ArticleWidget({super.key, required this.summary});

  final Summary summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        spacing: 10,
        children: [
          if (summary.hasImage)
            SizedBox(
              width: 300,
              height: 300,
              child: Image.network(summary.originalImage!.source),
            ),
          Text(
            summary.titles.normalized,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          if (summary.description != null)
            Text(
              summary.description!,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20,
                fontStyle: FontStyle.italic,
              ),
            ),
          Text(summary.extract),
        ],
      ),
    );
  }
}
