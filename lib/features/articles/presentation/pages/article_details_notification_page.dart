import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/services/di/injection_container_common.dart';
import 'package:medizen_app/base/widgets/not_found_data_page.dart';

import '../../../../base/theme/app_color.dart';
import '../../../../base/widgets/flexible_image.dart';
import '../../../../base/widgets/loading_page.dart';
import '../../data/model/article_model.dart';
import '../cubit/article_cubit/article_cubit.dart';

class ArticleDetailsNotificationPage extends StatelessWidget {
  final String articleId;

  const ArticleDetailsNotificationPage({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => ArticleCubit(
            remoteDataSource: serviceLocator(),
            networkInfo: serviceLocator(),
          )..getDetailsArticle(articleId: articleId, context: context),
      child: BlocConsumer<ArticleCubit, ArticleState>(
        listener: (context, state) {
          if (state is ArticleError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          } else if (state is FavoriteOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "articles.favorite_operation_success".tr(context),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<ArticleCubit>();
          ArticleModel? article;

          if (state is ArticleDetailsSuccess) {
            article = state.article;
          } else if (cubit.state is ArticleDetailsSuccess) {
            article = (cubit.state as ArticleDetailsSuccess).article;
          }

          if (state is ArticleLoading) {
            return LoadingPage();
          }

          return _buildScaffold(context, cubit, article, state);
        },
      ),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    ArticleCubit cubit,
    ArticleModel? article,
    ArticleState state,
  ) {
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
          if (article != null)
            state is FavoriteOperationLoading
                ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CupertinoActivityIndicator(),
                  ),
                )
                : IconButton(
                  icon: Icon(
                    article.isFavorite!
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: AppColors.primaryColor,
                  ),
                  tooltip:
                      article.isFavorite!
                          ? "articleDetails.actions.removeBookmark".tr(context)
                          : "articleDetails.actions.bookmark".tr(context),
                  onPressed: () => _handleBookmark(context, cubit, article),
                ),
        ],
      ),
      body: _buildBody(context, article, state),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ArticleModel? article,
    ArticleState state,
  ) {
    if (state is ArticleLoading) {
      return Center(child: LoadingPage());
    }

    if (article == null) {
      return NotFoundDataPage();
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.doctor != null) ...[
              const Gap(10),
              _buildDoctorInfo(context, article),
              const Gap(10),
            ],
            if (article.image != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
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
            const Gap(30),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorInfo(BuildContext context, ArticleModel article) {
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
        const Divider(),
      ],
    );
  }

  void _handleBookmark(
    BuildContext context,
    ArticleCubit cubit,
    ArticleModel article,
  ) {
    if (article.isFavorite!) {
      _showRemoveFromFavoritesDialog(context, cubit, article);
    } else {
      cubit.addArticleFavorite(articleId: article.id!, context: context);
    }
  }

  void _showRemoveFromFavoritesDialog(
    BuildContext context,
    ArticleCubit cubit,
    ArticleModel article,
  ) {
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
                cubit.removeArticleFavorite(
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
