import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/articles/data/model/article_model.dart';

import '../../../../base/theme/app_color.dart';
import '../../../../base/widgets/flexible_image.dart';
import '../cubit/article_cubit/article_cubit.dart';

class ArticleDetailsPage extends StatefulWidget {
  final ArticleModel article;

  const ArticleDetailsPage({super.key, required this.article});

  @override
  State<ArticleDetailsPage> createState() => _ArticleDetailsPageState();
}

class _ArticleDetailsPageState extends State<ArticleDetailsPage> {
  late ArticleModel _article;

  @override
  void initState() {
    super.initState();
    _article = widget.article;
  }

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
          BlocConsumer<ArticleCubit, ArticleState>(
            listener: (context, state) {
              if (state is FavoriteOperationSuccess) {
                setState(() {
                  _article = _article.copyWith(isFavorite: state.isFavorite);
                });
              }
              if (state is ArticleError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.error)));
              }
            },
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
                  _article.isFavorite! ? Icons.favorite : Icons.favorite_border,
                  color: AppColors.primaryColor,
                ),
                tooltip:
                    _article.isFavorite!
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
              if (_article.doctor != null) ...[
                const Gap(10),
                _buildDoctorInfo(context),
                const Gap(10),
              ],
              if (_article.image != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: FlexibleImage(
                    imageUrl: _article.image!,
                    height: 200,
                    width: double.infinity,
                  ),
                ),
                const Gap(16),
              ],
              if (_article.category != null) ...[
                Text(
                  "${"articleDetails.content.category".tr(context)}: ${_article.category!.display}",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(8),
              ],
              Text(
                _article.createdAt?.toLocal().toString().split(' ')[0] ?? '',
                style: const TextStyle(color: Colors.grey),
              ),
              const Gap(16),
              Text(
                _article.title ?? '',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cyan1,
                ),
              ),
              const Gap(16),
              Text(
                _article.content ?? '',
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
                  imageUrl: _article.doctor!.avatar,
                  assetPath: "assets/images/person.jpg",
                ),
              ),
              radius: 30,
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_article.doctor!.prefix} ${_article.doctor!.given} ${_article.doctor!.family}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (_article.doctor!.clinic != null)
                    Text(
                      _article.doctor!.clinic!.name,
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
    if (_article.isFavorite!) {
      _showRemoveFromFavoritesDialog(context);
    } else {
      context.read<ArticleCubit>().addArticleFavorite(
        articleId: _article.id!,
        context: context,
      );
    }
  }

  void _showRemoveFromFavoritesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "articleDetails.removeFavoriteTitle".tr(context),
            style: TextStyle(color: AppColors.primaryColor),
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
                  articleId: _article.id!,
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
