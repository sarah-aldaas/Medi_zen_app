// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:medizen_app/base/extensions/localization_extensions.dart';
//
// import '../../data/model/article_model.dart';
// import 'my_book_mark.dart';
//
// class ArticleDetailsPage extends StatelessWidget {
//   final ArticleModel article;
//
//   const ArticleDetailsPage({
//     super.key,
//     required this.article,
//     required String articleTitle,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.grey),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.bookmark_border, color: Colors.grey),
//             tooltip: "articleDetails.actions.bookmark".tr(context),
//             onPressed:
//                 () => Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => MyBookmarkPage()),
//                 ),
//           ),
//           IconButton(
//             icon: Icon(Icons.share, color: Colors.grey),
//             tooltip: "articleDetails.actions.share".tr(context),
//             onPressed: () {
//               // Handle share
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.more_vert, color: Colors.grey),
//             tooltip: "articleDetails.actions.more".tr(context),
//             onPressed: () {
//               // Handle more options
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8.0),
//                 child: Image.asset(article.imageUrl, fit: BoxFit.fill),
//               ),
//               Gap(5),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "${"articleDetails.content.category".tr(context)}: ${article.category}",
//                     style: TextStyle(
//                       color: Theme.of(context).primaryColor,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     "${"articleDetails.content.published".tr(context)} ${article.date}",
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 16),
//               Text(
//                 article.title,
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 16),
//               Text(
//                 article.content,
//                 style: Theme.of(context).textTheme.bodyMedium,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/features/articles/data/model/article_model.dart';

class ArticleDetailsPage extends StatelessWidget {
  final ArticleModel article;

  const ArticleDetailsPage({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.grey),
            tooltip: "articleDetails.actions.bookmark".tr(context),
            onPressed: () => _handleBookmark(context),
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.grey),
            tooltip: "articleDetails.actions.share".tr(context),
            onPressed: () => _shareArticle(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article.image != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    article.image!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const Gap(16),
              ],
              if (article.category != null) ...[
                Text(
                  "${"articleDetails.content.category".tr(context)}: ${article.category!.display}",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(8),
              ],
              Text(
                article.createdAt?.toLocal().toString().split(' ')[0] ?? '',
                style: const TextStyle(color: Colors.grey),
              ),
              const Gap(16),
              Text(
                article.title ?? '',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Gap(16),
              Text(
                article.content ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (article.doctor != null) ...[
                const Gap(24),
                _buildDoctorInfo(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Gap(8),
        Text(
          "articleDetails.author".tr(context),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const Gap(8),
        Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(article.doctor!.avatar ?? ''),
              radius: 30,
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${article.doctor!.prefix} ${article.doctor!.given} ${article.doctor!.family}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (article.doctor!.clinic != null)
                    Text(
                      article.doctor!.clinic!.name,
                      style: const TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleBookmark(BuildContext context) {
    // Implement bookmark functionality using your cubit
    // Example: context.read<ArticleCubit>().addArticleFavorite(articleId: article.id!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("articleDetails.bookmarkAdded".tr(context))),
    );
  }

  void _shareArticle(BuildContext context) {
    // Implement share functionality
    // Example: Share.share('Check out this article: ${article.title}\n${article.content?.substring(0, 100)}...');
  }
}