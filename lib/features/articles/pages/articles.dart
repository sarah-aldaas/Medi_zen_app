import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/extensions/media_query_extension.dart';
import 'package:medizen_app/base/go_router/go_router.dart';

import '../model/article_model.dart';
import 'article_details_page.dart';
import 'mixin/article_mixin.dart';

class Articles extends StatefulWidget {
  const Articles({super.key});

  @override
  _ArticlesState createState() => _ArticlesState();
}

class _ArticlesState extends State<Articles> with ArticleMixin {
  late String _selectedFilter; // Default filter
  @override
  void initState() {
    _selectedFilter = "articles.filters.newest".tr(context);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "articles.title".tr(context),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_ios, color: Colors.grey),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.grey),
            tooltip: "articles.actions.search".tr(context),
            onPressed: () {
              // Handle search
            },
          ),
          IconButton(
            icon: Icon(Icons.bookmark_border, color: Colors.grey),
            tooltip: "articles.actions.bookmark".tr(context),
            onPressed: () => context.pushNamed(AppRouter.myBookMark.name),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTrendingSection(context: context),
              SizedBox(height: 20),
              _buildArticlesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingSection({required BuildContext context}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "articles.trending".tr(context),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                // Navigate to see all trending
              },
              child: Text(
                "articles.seeAll".tr(context),
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                trendingArticles
                    .map(
                      (article) => _buildTrendingArticleCard(
                        article: article,
                        context: context,
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingArticleCard({
    required ArticleModel article,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      ArticleDetailsPage(article: article, articleTitle: ''),
            ),
          ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: context.width / 1.9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(article.imageUrl, fit: BoxFit.fill),
              ),
              SizedBox(height: 8),
              Text(
                article.title,
                style: TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticlesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "articles.title".tr(context),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                // Navigate to see all articles
              },
              child: Text(
                "articles.seeAll".tr(context),
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildArticleFilterButton(
                text: "articles.filters.newest".tr(context),
              ),
              SizedBox(width: 8),
              _buildArticleFilterButton(
                text: "articles.filters.health".tr(context),
              ),
              SizedBox(width: 8),
              _buildArticleFilterButton(
                text: "articles.filters.covid".tr(context),
              ),
              SizedBox(width: 8),
              _buildArticleFilterButton(
                text: "articles.filters.lifestyle".tr(context),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        ...healthArticles
            .map((article) => _buildArticleItem(article: article))
            .toList(),
      ],
    );
  }

  Widget _buildArticleFilterButton({required String text}) {
    return ElevatedButton(
      onPressed: () => setState(() => _selectedFilter = text),
      child: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _selectedFilter == text
                ? Theme.of(context).primaryColor
                : Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: _selectedFilter == text ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  Widget _buildArticleItem({required ArticleModel article}) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      ArticleDetailsPage(article: article, articleTitle: ''),
            ),
          ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                article.imageUrl,
                height: 100,
                width: 100,
                fit: BoxFit.fill,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.date,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(height: 4),
                  Text(
                    article.title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    article.category,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
