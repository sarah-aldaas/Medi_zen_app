import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/services/di/injection_container_common.dart';

import '../../../../base/theme/app_color.dart';
import '../../../../base/widgets/flexible_image.dart';
import '../../../../base/widgets/loading_page.dart';
import '../../data/model/article_model.dart';
import '../cubit/article_cubit/article_cubit.dart';

class ArticleDetailsNotificationPage extends StatefulWidget {
  final String articleId;

  const ArticleDetailsNotificationPage({super.key, required this.articleId});

  @override
  State<ArticleDetailsNotificationPage> createState() =>
      _ArticleDetailsNotificationPageState();
}

class _ArticleDetailsNotificationPageState
    extends State<ArticleDetailsNotificationPage> {
  ArticleModel? _article;
  late ArticleCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ArticleCubit(
      remoteDataSource: serviceLocator(),
    );
    _cubit.getDetailsArticle(articleId: widget.articleId, context: context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<ArticleCubit, ArticleState>(
        listener: (context, state) {
          if (state is ArticleDetailsSuccess) {
            _article = state.article;
          } else if (state is FavoriteOperationSuccess) {
            setState(() {
              _article = _article?.copyWith(isFavorite: state.isFavorite);
            });
          } else if (state is ArticleError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        child: Scaffold(
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
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CupertinoActivityIndicator(),
                    );
                  }
                  return IconButton(
                    icon: Icon(
                      (_article?.isFavorite ?? false)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: AppColors.primaryColor,
                    ),
                    onPressed: () => _handleBookmark(context),
                  );
                },
              ),
            ],
          ),
          body: BlocBuilder<ArticleCubit, ArticleState>(
            builder: (context, state) {
              if (_article == null ||
                  state is ArticleLoading ||
                  state is ArticleInitial) {
                return const LoadingPage();
              }
              return _buildBody(context);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final article = _article!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.doctor != null) ...[
            const Gap(10),
            _buildDoctorInfo(article),
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
            style: const TextStyle(
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
    );
  }

  Widget _buildDoctorInfo(ArticleModel article) {
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

  void _handleBookmark(BuildContext context) {
    if (_article == null) return;

    if (_article!.isFavorite ?? false) {
      _showRemoveFromFavoritesDialog(context);
    } else {
      _cubit.addArticleFavorite(articleId: _article!.id!, context: context);
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
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text("articleDetails.removeFavoriteMessage".tr(context)),
          actions: <Widget>[
            TextButton(
              child: Text(
                "articleDetails.cancel".tr(context),
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                "articleDetails.remove".tr(context),
                style: TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _cubit.removeArticleFavorite(
                  articleId: _article!.id!,
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
