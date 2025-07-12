import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/articles/data/model/article_model.dart';

import '../../../../base/theme/app_color.dart';
import '../../../../base/widgets/flexible_image.dart';
import '../cubit/article_cubit/article_cubit.dart';

class ArticleDetailsPage extends StatelessWidget {
  final ArticleModel article;

  const ArticleDetailsPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'articles.article_details'.tr(context),
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          BlocBuilder<ArticleCubit, ArticleState>(
            builder: (context, state) {
              if (state is FavoriteOperationLoading) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: LoadingButton(),
                  ),
                );
              }
              return IconButton(
                icon: Icon(
                  article.isFavorite! ? Icons.favorite : Icons.favorite_border,
                  color: AppColors.primaryColor,
                ),
                tooltip:
                    article.isFavorite!
                        ? "articleDetails.actions.removeBookmark".tr(context)
                        : "articleDetails.actions.bookmark".tr(context),
                onPressed: () => _handleBookmark(context),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article.doctor != null) ...[
                const Gap(10),
                _buildDoctorInfo(context),
                const Gap(10),
              ],
              if (article.image != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  // child: Image.network(article.image!, height: 200, width: double.infinity, fit: BoxFit.cover),
                  child: FlexibleImage(
                    imageUrl: article.image!,
                    height: 200,
                    width: double.infinity,
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
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cyan1,
                ),
              ),
              const Gap(16),
              Text(
                article.content ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Gap(30),
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
        const Gap(8),
        Text(
          "articleDetails.author".tr(context),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.cyan1,
          ),
        ),
        const Gap(8),
        Row(
          children: [
            CircleAvatar(
              child: ClipOval(
                child: FlexibleImage(
                  imageUrl: article.doctor!.avatar,
                  assetPath: "assets/images/person.jpg",
                ),
              ),
              // backgroundImage: NetworkImage(article.doctor!.avatar ?? ''),
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
        const Gap(8),
        Divider(),
      ],
    );
  }

  void _handleBookmark(BuildContext context) {
    if (article.isFavorite!) {
      _showRemoveFromFavoritesDialog(context);
      article.copyWith(isFavorite: false);
    } else {
      context.read<ArticleCubit>().addArticleFavorite(
        articleId: article.id!,
        context: context,
      );
      article.copyWith(isFavorite: true);
    }
  }

  void _showRemoveFromFavoritesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "articleDetails.removeFavoriteTitle".tr(context),
            style: TextStyle(
              color: AppColors.primaryColor,

            ),
          ),
          content: Text("articleDetails.removeFavoriteMessage".tr(context)),
          actions: <Widget>[
            TextButton(
              child: Text(
                "articleDetails.cancel".tr(context),
                style: TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                "articleDetails.remove".tr(context),
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();

                context.read<ArticleCubit>().removeArticleFavorite(
                  articleId: article.id!,
                  context: context,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
