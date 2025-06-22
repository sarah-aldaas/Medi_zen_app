import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/features/articles/pages/my_book_mark.dart';

import '../model/article_model.dart';

class ArticleDetailsPage extends StatelessWidget {
  final ArticleModel article;

  const ArticleDetailsPage({
    super.key,
    required this.article,
    required String articleTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark_border, color: Colors.grey),
            tooltip: "articleDetails.actions.bookmark".tr(context),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyBookmarkPage()),
                ),
          ),
          IconButton(
            icon: Icon(Icons.share, color: Colors.grey),
            tooltip: "articleDetails.actions.share".tr(context),
            onPressed: () {
              // Handle share
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.grey),
            tooltip: "articleDetails.actions.more".tr(context),
            onPressed: () {
              // Handle more options
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(article.imageUrl, fit: BoxFit.fill),
              ),
              Gap(5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${"articleDetails.content.category".tr(context)}: ${article.category}",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${"articleDetails.content.published".tr(context)} ${article.date}",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                article.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                article.content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
