// import 'package:flutter/material.dart';
// import 'package:medizen_app/base/extensions/localization_extensions.dart';
//
// import 'mixin/article_mixin.dart';
//
// class MyBookmarkPage extends StatelessWidget with ArticleMixin {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//         title: Text(
//           "bookmark.title".tr(context),
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.grey),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.search, color: Colors.grey),
//             tooltip: "bookmark.actions.search".tr(context),
//             onPressed: () {},
//           ),
//           IconButton(
//             icon: Icon(Icons.more_vert, color: Colors.grey),
//             tooltip: "bookmark.actions.more".tr(context),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: ListView.builder(
//           itemCount: bookmarkArticles.length,
//           itemBuilder: (context, index) {
//             final article = bookmarkArticles[index];
//             return Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(8.0),
//                     child: Image.asset(
//                       article.imageUrl,
//                       height: 100,
//                       width: 100,
//                       fit: BoxFit.fill,
//                     ),
//                   ),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           article.date,
//                           style: TextStyle(fontSize: 12, color: Colors.grey),
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           article.title,
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           article.category,
//                           style: TextStyle(
//                             color: Theme.of(context).primaryColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/features/articles/data/model/article_model.dart';
import 'package:medizen_app/features/articles/presentation/pages/article_details_page.dart';

import '../../../../base/data/models/code_type_model.dart';

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace with your actual bookmarked articles from cubit
    final bookmarkedArticles = List.generate(5, (index) => ArticleModel(
      id: 'bookmark$index',
      title: 'Bookmarked Article ${index + 1}',
      content: 'Content for bookmarked article ${index + 1}',
      category: CodeModel(
        id: index.toString(),
        code: 'CAT$index',
        display: 'Category ${index + 1}', description: '', codeTypeId: '',
      ),
      createdAt: DateTime.now().subtract(Duration(days: index)),
    ));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "bookmark.title".tr(context),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.grey),
            tooltip: "bookmark.actions.search".tr(context),
            onPressed: () {},
          ),
        ],
      ),
      body: bookmarkedArticles.isEmpty
          ? Center(
        child: Text("bookmark.empty".tr(context)),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookmarkedArticles.length,
        itemBuilder: (context, index) {
          final article = bookmarkedArticles[index];
          return _buildBookmarkItem(article: article, context: context);
        },
      ),
    );
  }

  Widget _buildBookmarkItem({
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
              IconButton(
                icon: const Icon(Icons.bookmark, color: Colors.amber),
                onPressed: () {
                  // Implement remove bookmark
                  // Example: context.read<ArticleCubit>().removeArticleFavorite(articleId: article.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("bookmark.removed".tr(context))),
                  );
                },
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
}