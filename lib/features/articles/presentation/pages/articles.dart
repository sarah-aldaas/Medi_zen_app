// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:medizen_app/base/extensions/localization_extensions.dart';
// import 'package:medizen_app/base/extensions/media_query_extension.dart';
// import '../../../../base/go_router/go_router.dart';
// import '../../data/model/article_model.dart';
// import 'article_details_page.dart';
// import 'mixin/article_mixin.dart';
//
// class Articles extends StatefulWidget {
//   const Articles({super.key});
//
//   @override
//   _ArticlesState createState() => _ArticlesState();
// }
//
// class _ArticlesState extends State<Articles> with ArticleMixin {
//   late String _selectedFilter;
//   @override
//   void initState() {
//     _selectedFilter = "articles.filters.newest".tr(context);
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//         title: Text(
//           "articles.title".tr(context),
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         leading: IconButton(
//           onPressed: () => Navigator.of(context).pop(),
//           icon: Icon(Icons.arrow_back, color: Colors.grey),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.search, color: Colors.grey),
//             tooltip: "articles.actions.search".tr(context),
//             onPressed: () {
//               // Handle search
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.bookmark_border, color: Colors.grey),
//             tooltip: "articles.actions.bookmark".tr(context),
//             onPressed: () => context.pushNamed(AppRouter.myBookMark.name),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildTrendingSection(context: context),
//               SizedBox(height: 20),
//               _buildArticlesSection(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTrendingSection({required BuildContext context}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               "articles.trending".tr(context),
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             TextButton(
//               onPressed: () {},
//               child: Text(
//                 "articles.seeAll".tr(context),
//                 style: TextStyle(color: Theme.of(context).primaryColor),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 10),
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children:
//                 trendingArticles
//                     .map(
//                       (article) => _buildTrendingArticleCard(
//                         article: article,
//                         context: context,
//                       ),
//                     )
//                     .toList(),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTrendingArticleCard({
//     required ArticleModel article,
//     required BuildContext context,
//   }) {
//     return GestureDetector(
//       onTap:
//           () => Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder:
//                   (context) =>
//                       ArticleDetailsPage(article: article, articleTitle: ''),
//             ),
//           ),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: SizedBox(
//           width: context.width / 1.9,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8.0),
//                 child: Image.asset(article.imageUrl, fit: BoxFit.fill),
//               ),
//               SizedBox(height: 8),
//               Text(
//                 article.title,
//                 style: TextStyle(fontWeight: FontWeight.bold),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildArticlesSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               "articles.title".tr(context),
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             TextButton(
//               onPressed: () {},
//               child: Text(
//                 "articles.seeAll".tr(context),
//                 style: TextStyle(color: Theme.of(context).primaryColor),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 10),
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children: [
//               _buildArticleFilterButton(
//                 text: "articles.filters.newest".tr(context),
//               ),
//               SizedBox(width: 8),
//               _buildArticleFilterButton(
//                 text: "articles.filters.health".tr(context),
//               ),
//               SizedBox(width: 8),
//               _buildArticleFilterButton(
//                 text: "articles.filters.covid".tr(context),
//               ),
//               SizedBox(width: 8),
//               _buildArticleFilterButton(
//                 text: "articles.filters.lifestyle".tr(context),
//               ),
//             ],
//           ),
//         ),
//         SizedBox(height: 16),
//         ...healthArticles
//             .map((article) => _buildArticleItem(article: article))
//             .toList(),
//       ],
//     );
//   }
//
//   Widget _buildArticleFilterButton({required String text}) {
//     return ElevatedButton(
//       onPressed: () => setState(() => _selectedFilter = text),
//       child: Text(text),
//       style: ElevatedButton.styleFrom(
//         backgroundColor:
//             _selectedFilter == text
//                 ? Theme.of(context).primaryColor
//                 : Theme.of(context).scaffoldBackgroundColor,
//         foregroundColor: _selectedFilter == text ? Colors.white : Colors.black,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20.0),
//           side: BorderSide(color: Theme.of(context).primaryColor),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildArticleItem({required ArticleModel article}) {
//     return GestureDetector(
//       onTap:
//           () => Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder:
//                   (context) =>
//                       ArticleDetailsPage(article: article, articleTitle: ''),
//             ),
//           ),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(8.0),
//               child: Image.asset(
//                 article.imageUrl,
//                 height: 100,
//                 width: 100,
//                 fit: BoxFit.fill,
//               ),
//             ),
//             SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     article.date,
//                     style: TextStyle(fontSize: 12, color: Colors.grey),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     article.title,
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     article.category,
//                     style: TextStyle(color: Theme.of(context).primaryColor),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/extensions/media_query_extension.dart';
import 'package:medizen_app/features/articles/data/model/article_model.dart';
import 'package:medizen_app/features/articles/presentation/pages/article_details_page.dart';

import '../../../../base/data/models/code_type_model.dart';
import '../cubit/article_cubit/article_cubit.dart';

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  @override
  void initState() {
    context.read<ArticleCubit>().getAllArticles(context: context);
    super.initState();
  }
  String _selectedFilter = "articles.filters.newest";
  final List<String> _filters = [
    "articles.filters.newest",
    "articles.filters.health",
    "articles.filters.covid",
    "articles.filters.lifestyle"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "articles.title".tr(context),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.grey),
            tooltip: "articles.actions.search".tr(context),
            onPressed: () => _showSearch(context),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.grey),
            tooltip: "articles.actions.bookmark".tr(context),
            onPressed: () => context.pushNamed('bookmarks'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Implement refresh logic
          context.read<ArticleCubit>().getAllArticles(context: context);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildTrendingSection(context),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: _buildFilterSection(context),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: _buildArticlesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "articles.trending".tr(context),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  "articles.seeAll".tr(context),
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3, // Replace with your trending articles count
              itemBuilder: (context, index) {
                // Replace with your trending article data
                final article = ArticleModel(
                  id: '$index',
                  title: 'Trending Article ${index + 1}',
                  content: 'Sample content',
                  category: CodeModel(
                    id: index.toString(),
                    code: 'CODE',
                    display: 'Category ${index + 1}', description: '', codeTypeId: '',
                  ),
                );
                return _buildTrendingArticleCard(article: article, context: context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingArticleCard({
    required ArticleModel article,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () => _navigateToDetails(article, context),
      child: Container(
        width: context.width / 1.5,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  color: Colors.grey[200],
                  child: article.image != null
                      ? Image.network(
                    article.image!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  )
                      : const Icon(Icons.article, size: 50),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              article.title ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (article.category != null)
              Text(
                article.category!.display,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _filters
                .map((filter) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter.tr(context)),
                selected: _selectedFilter == filter,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = selected ? filter : _filters[0];
                  });
                  // Implement filter logic
                },
                selectedColor: Theme.of(context).primaryColor,
                labelStyle: TextStyle(
                  color: _selectedFilter == filter
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildArticlesList() {
    // Replace with your actual articles list from cubit
    final articles = List.generate(10, (index) => ArticleModel(
      id: '$index',
      title: 'Article Title ${index + 1}',
      content: 'Content for article ${index + 1}',
      category: CodeModel(
        id: index.toString(),
        code: 'CAT$index',
        display: 'Category ${index + 1}', description: '', codeTypeId: '',
      ),
      createdAt: DateTime.now().subtract(Duration(days: index)),
    ));

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final article = articles[index];
          return _buildArticleItem(article: article, context: context);
        },
        childCount: articles.length,
      ),
    );
  }

  Widget _buildArticleItem({
    required ArticleModel article,
    required BuildContext context,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToDetails(article, context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: article.image != null
                      ? Image.network(
                    article.image!,
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.article, size: 40),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (article.category != null)
                      Text(
                        article.category!.display,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      article.title ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.createdAt?.toLocal().toString().split(' ')[0] ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetails(ArticleModel article, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailsPage(article: article),
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: ArticleSearchDelegate(),
    );
  }
}

class ArticleSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Implement search results
    return Center(
      child: Text('Search results for: $query'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Implement search suggestions
    return Center(
      child: Text('Search suggestions for: $query'),
    );
  }
}