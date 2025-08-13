import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';

import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/data/models/public_response_model.dart';
import '../../../../../base/go_router/go_router.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../data/data_sources/articles_remote_data_sources.dart';
import '../../../data/model/ai_model.dart';
import '../../../data/model/article_model.dart';

part 'article_state.dart';

class ArticleCubit extends Cubit<ArticleState> {
  final ArticlesRemoteDataSource remoteDataSource;

  ArticleCubit({required this.remoteDataSource}) : super(ArticleInitial());

  int _currentPage = 1;
  bool _hasMore = true;
  Map<String, dynamic> _currentFilters = {};
  List<ArticleModel> _allArticles = [];

  Future<void> getAllArticles({
    Map<String, dynamic>? filters,
    bool loadMore = false,
    required BuildContext context,
    int perPage = 6,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allArticles = [];
      emit(ArticleLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    final result = await remoteDataSource.getAllArticles(
      filters: _currentFilters,
      page: _currentPage,
      perPage: perPage,
    );

    if (result is Success<PaginatedResponse<ArticleModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
        return;
      }
      try {
        _allArticles.addAll(result.data.paginatedData!.items);
        _hasMore =
            result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage!;
        _currentPage++;

        emit(
          ArticleSuccess(
            hasMore: _hasMore,
            paginatedResponse: PaginatedResponse<ArticleModel>(
              paginatedData: PaginatedData<ArticleModel>(items: _allArticles),
              meta: result.data.meta,
              links: result.data.links,
            ),
          ),
        );
      } catch (e) {
        emit(
          ArticleError(
            error: result.data.msg ?? 'failed_to_fetch_articles'.tr(context),
          ),
        );
      }
    } else if (result is ResponseError<PaginatedResponse<ArticleModel>>) {
      emit(
        ArticleError(
          error: result.message ?? 'failed_to_fetch_articles'.tr(context),
        ),
      );
    }
  }

  Future<void> getMyFavoriteArticles({
    Map<String, dynamic>? filters,
    bool loadMore = false,
    required BuildContext context,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allArticles = [];
      emit(ArticleLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    final result = await remoteDataSource.getMyFavoriteArticles(
      filters: _currentFilters,
      page: _currentPage,
      perPage: 10,
    );

    if (result is Success<PaginatedResponse<ArticleModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
        return;
      }
      try {
        _allArticles.addAll(result.data.paginatedData!.items);
        _hasMore =
            result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(
          ArticleSuccess(
            hasMore: _hasMore,
            paginatedResponse: PaginatedResponse<ArticleModel>(
              paginatedData: PaginatedData<ArticleModel>(items: _allArticles),
              meta: result.data.meta,
              links: result.data.links,
            ),
          ),
        );
      } catch (e) {
        emit(
          ArticleError(
            error:
                result.data.msg ??
                'failed_to_fetch_favorite_articles'.tr(context),
          ),
        );
      }
    } else if (result is ResponseError<PaginatedResponse<ArticleModel>>) {
      emit(
        ArticleError(
          error:
              result.message ?? 'failed_to_fetch_favorite_articles'.tr(context),
        ),
      );
    }
  }

  Future<void> getDetailsArticle({
    required String articleId,
    required BuildContext context,
  }) async {
    emit(ArticleLoading());

    try {
      final result = await remoteDataSource.getDetailsArticle(
        articleId: articleId,
      );

      if (result is Success<ArticleModel>) {
        if (result.data.toString().contains("Unauthorized")) {
          context.pushReplacementNamed(AppRouter.welcomeScreen.name);
          return;
        }
        emit(ArticleDetailsSuccess(article: result.data));
      } else if (result is ResponseError<ArticleModel>) {
        emit(
          ArticleError(
            error:
                result.message ?? 'failed_to_fetch_article_details'.tr(context),
          ),
        );
        await Future.delayed(Duration(milliseconds: 300));
        emit(ArticleInitial());
      }
    } catch (e) {
      emit(ArticleError(error: e.toString()));
      await Future.delayed(Duration(milliseconds: 300));
      emit(ArticleInitial());
    }
  }

  Future<void> getArticleOfCondition({
    required String conditionId,
    required BuildContext context,
  }) async {
    emit(ArticleLoading());
    try {
      final result = await remoteDataSource.getArticleOfCondition(
        conditionId: conditionId,
      );
      if (result is Success<ArticleResponseModel>) {
        if (result.data.toString().contains("Unauthorized")) {
          context.pushReplacementNamed(AppRouter.welcomeScreen.name);
          return;
        }
        if (result.data.status) {
          if (result.data.articleModel != null) {
            emit(ArticleConditionSuccess(article: result.data.articleModel));
          } else {
            ShowToast.showToastInfo(message: "You should generate first");
            emit(ArticleInitial());
          }
        } else {
          emit(
            ArticleError(
              error:
                  result.data.msg ??
                  'failed_to_fetch_condition_article'.tr(context),
            ),
          );
        }
      } else if (result is ResponseError<ArticleResponseModel>) {
        emit(
          ArticleError(
            error:
                result.message ??
                'failed_to_fetch_condition_article'.tr(context),
          ),
        );
      }
    } catch (e) {
      emit(ArticleError(error: "You should generate article first."));
    }
  }

  Future<void> addArticleFavorite({
    required String articleId,
    required BuildContext context,
  }) async {
    emit(FavoriteOperationLoading());
    try {
      final result = await remoteDataSource.addArticleFavorite(
        articleId: articleId,
      );

      if (result is Success<PublicResponseModel>) {
        if (result.data.msg == "Unauthorized. Please login first.") {
          context.pushReplacementNamed(AppRouter.welcomeScreen.name);
          return;
        }
        emit(FavoriteOperationSuccess(isFavorite: true));
        ShowToast.showToastSuccess(message: 'added_to_favorites'.tr(context));
        await getDetailsArticle(articleId: articleId, context: context);
      } else if (result is ResponseError<PublicResponseModel>) {
        emit(
          ArticleError(
            error: result.message ?? 'failed_to_add_favorite'.tr(context),
          ),
        );
        await Future.delayed(Duration(milliseconds: 300));
        emit(ArticleInitial());
      }
    } catch (e) {
      emit(ArticleError(error: e.toString()));
      await Future.delayed(Duration(milliseconds: 300));
      emit(ArticleInitial());
    }
  }

  Future<void> removeArticleFavorite({
    required String articleId,
    required BuildContext context,
  }) async {
    emit(FavoriteOperationLoading());

    try {
      final result = await remoteDataSource.removeArticleFavorite(
        articleId: articleId,
      );

      if (result is Success<PublicResponseModel>) {

        if (result.data.msg?.contains("Unauthorized") == true) {
          if (context.mounted) {
            context.pushReplacementNamed(AppRouter.welcomeScreen.name);
          }
          return;
        }


        if (result.data.status == true) {
          emit(FavoriteOperationSuccess(isFavorite: false));


          if (context.mounted) {
            ShowToast.showToastSuccess(
              message: 'article.removed_from_favorites'.tr(context),
            );
          }

          await Future.wait([
            getDetailsArticle(articleId: articleId, context: context),
            getMyFavoriteArticles(context: context),
          ]);
        } else {
          final errorMsg =
              result.data.msg ?? 'article.failed_to_remove'.tr(context);
          emit(ArticleError(error: errorMsg));
          if (context.mounted) {
            ShowToast.showToastError(message: errorMsg);
          }
        }
      } else if (result is ResponseError<PublicResponseModel>) {
        final errorMsg =
            result.message ?? 'article.failed_to_remove'.tr(context);
        emit(ArticleError(error: errorMsg));
        if (context.mounted) {
          ShowToast.showToastError(message: errorMsg);
        }
      }
    } catch (e) {
      final errorMsg = 'article.removal_error'.tr(context);
      debugPrint('Error removing favorite: $e');
      emit(ArticleError(error: errorMsg));
      if (context.mounted) {
        ShowToast.showToastError(message: errorMsg);
      }
    } finally {
      if (context.mounted) {
        await Future.delayed(const Duration(milliseconds: 300));
        emit(ArticleInitial());
      }
    }
  }

  DateTime? lastGenerationTime;
  int generationCount = 0;

  Future<void> generateAiArticle({
    required String conditionId,
    required String? apiModel,
    required String language,
    required BuildContext context,
  }) async {
    emit(ArticleGenerateLoading());

    try {
      if (language.isEmpty) {
        language = await _showLanguageSelectionDialog(context);
        if (language.isEmpty) {
          emit(ArticleError(error: 'language_selection_cancelled'.tr(context)));
          return;
        }
      }

      if (apiModel == null) {
        apiModel = await _showModelSelectionDialog(context);
        if (apiModel == null) {
          emit(ArticleError(error: 'model_selection_cancelled'.tr(context)));
          return;
        }
      }

      final response = await remoteDataSource.generateAiArticle(
        conditionId: conditionId,
        apiModel: apiModel,
        language: language,
      );

      if (response is Success<PublicResponseModel>) {
        if (response.data.msg == "Unauthorized. Please login first.") {
          context.pushReplacementNamed(AppRouter.welcomeScreen.name);
          return;
        }
        if (response.data.status) {
          lastGenerationTime = DateTime.now();
          generationCount++;

          emit(ArticleGenerateSuccess(response: response.data));
          ShowToast.showToastSuccess(message: response.data.msg);
        } else {
          emit(ArticleError(error: response.data.msg));
          ShowToast.showToastError(message: response.data.msg);
        }
      } else if (response is ResponseError<PublicResponseModel>) {
        emit(
          ArticleError(
            error: response.message ?? 'failed_to_generate_article'.tr(context),
          ),
        );
        ShowToast.showToastError(
          message: response.message ?? 'failed_to_generate_article'.tr(context),
        );
      }
    } catch (e) {
      emit(ArticleError(error: e.toString()));
      ShowToast.showToastError(message: e.toString());
    }
  }

  Future<String> _showLanguageSelectionDialog(BuildContext context) async {
    return await showDialog<String>(
          context: context,
          builder:
              (context) => AlertDialog(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                title: Text("select_language".tr(context)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text("English"),
                      onTap: () => Navigator.pop(context, "en"),
                    ),
                    ListTile(
                      title: Text("العربية"),
                      onTap: () => Navigator.pop(context, "ar"),
                    ),
                  ],
                ),
              ),
        ) ??
        "";
  }

  Future<String?> _showModelSelectionDialog(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Text("articles.select_model".tr(context)),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: listModels.length,
                itemBuilder: (context, index) {
                  final model = listModels[index];
                  return ListTile(
                    title: Text(model.nameModel),
                    onTap: () => Navigator.pop(context, model.apiModel),
                  );
                },
              ),
            ),
          ),
    );
  }
}
