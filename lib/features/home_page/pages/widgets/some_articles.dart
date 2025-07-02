import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/articles/data/model/article_model.dart';
import 'package:medizen_app/features/articles/presentation/cubit/article_cubit/article_cubit.dart';
import 'package:medizen_app/features/articles/presentation/pages/article_details_page.dart';

class SimpleArticlesPage extends StatefulWidget {
  const SimpleArticlesPage({super.key});

  @override
  State<SimpleArticlesPage> createState() => _SimpleArticlesPageState();
}

class _SimpleArticlesPageState extends State<SimpleArticlesPage> {
  @override
  void initState() {
    super.initState();
    _loadInitialArticles();
  }

  void _loadInitialArticles() {
    context.read<ArticleCubit>().getAllArticles(perPage: 5, context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "articles.title".tr(context),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        ),
        BlocConsumer<ArticleCubit, ArticleState>(
          listener: (context, state) {
            if (state is ArticleError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error)));
            }
          },
          builder: (context, state) {
            if (state is ArticleLoading) {
              return Center(child: LoadingButton());
            }

            if (state is ArticleError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.error),
                    ElevatedButton(
                      onPressed: _loadInitialArticles,
                      child: Text("Retry".tr(context)),
                    ),
                  ],
                ),
              );
            }

            final articles =
                (state is ArticleSuccess)
                    ? state.paginatedResponse.paginatedData?.items ?? []
                    : [];

            return ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => SizedBox(height: 8),
              padding: const EdgeInsets.all(16),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                return _buildArticleItem(
                  article: articles[index],
                  context: context,
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildArticleItem({
    required ArticleModel article,
    required BuildContext context,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: () => _navigateToDetails(article, context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child:
                      article.image != null && article.image!.isNotEmpty
                          ? Image.network(
                            article.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(Icons.article),
                          )
                          : Icon(Icons.article, size: 40),
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
                          fontSize: 13,
                        ),
                        // textDirection: article.language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      article.title ?? 'No title',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      // textDirection: article.language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.createdAt?.toLocal().toString().split(' ')[0] ??
                          '',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      // textDirection: article.language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
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
    ).then((value) {
      _loadInitialArticles();
    });
  }
}
