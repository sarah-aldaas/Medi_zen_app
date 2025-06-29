import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/articles/data/model/article_model.dart';

import '../cubit/article_cubit/article_cubit.dart';

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
          BlocBuilder<ArticleCubit, ArticleState>(
  builder: (context, state) {
    if(state is FavoriteOperationLoading){
      return Center(child:Padding(
        padding: const EdgeInsets.all(8.0),
        child: LoadingButton(),
      ) ,);
    }
    return IconButton(
                icon: Icon(
                  article.isFavorite! ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.grey,
                ),
                tooltip: article.isFavorite!
                    ? "articleDetails.actions.removeBookmark".tr(context)
                    : "articleDetails.actions.bookmark".tr(context),
                onPressed: () => _handleBookmark(context),
              );
  },
)
           
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
    if (article.isFavorite!) {
      _showRemoveFromFavoritesDialog(context);
    } else {
      // Add to favorites logic
      // You'll need to access your ArticleCubit here
      context.read<ArticleCubit>().addArticleFavorite(articleId: article.id!, context: context);
    }
  }

  void _showRemoveFromFavoritesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("articleDetails.removeFavoriteTitle".tr(context)),
          content: Text("articleDetails.removeFavoriteMessage".tr(context)),
          actions: <Widget>[
            TextButton(
              child: Text("articleDetails.cancel".tr(context)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("articleDetails.remove".tr(context)),
              onPressed: () {
                Navigator.of(context).pop();
                // Remove from favorites logic
                // You'll need to access your ArticleCubit here
                context.read<ArticleCubit>().removeArticleFavorite(articleId:article.id! ,context: context);
              },
            ),
          ],
        );
      },
    );
  }
}