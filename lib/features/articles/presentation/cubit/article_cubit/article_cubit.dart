import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/services/network/network_info.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import 'package:meta/meta.dart';

import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/data/models/public_response_model.dart';
import '../../../../../base/go_router/go_router.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../data/data_sources/articles_remote_data_sources.dart';
import '../../../data/model/article_model.dart';

part 'article_state.dart';

class ArticleCubit extends Cubit<ArticleState> {
  final ArticlesRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ArticleCubit({required this.remoteDataSource, required this.networkInfo}) : super(ArticleInitial());

  int _currentPage = 1;
  bool _hasMore = true;
  Map<String, dynamic> _currentFilters = {};
  List<ArticleModel> _allArticles = [];

  Future<void> getAllArticles({Map<String, dynamic>? filters, bool loadMore = false, required BuildContext context}) async {
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

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed('noInternet');
      emit(ArticleError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

    final result = await remoteDataSource.getAllArticles(filters: _currentFilters, page: _currentPage, perPage: 10);

    if (result is Success<PaginatedResponse<ArticleModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      try {
        _allArticles.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty && result.data.meta!.currentPage < result.data.meta!.lastPage;
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
        emit(ArticleError(error: result.data.msg ?? 'Failed to fetch articles'));
      }
    } else if (result is ResponseError<PaginatedResponse<ArticleModel>>) {
      emit(ArticleError(error: result.message ?? 'Failed to fetch articles'));
    }
  }

  Future<void> getMyFavoriteArticles({Map<String, dynamic>? filters, bool loadMore = false, required BuildContext context}) async {
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

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed('noInternet');
      emit(ArticleError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

    final result = await remoteDataSource.getMyFavoriteArticles(filters: _currentFilters, page: _currentPage, perPage: 10);

    if (result is Success<PaginatedResponse<ArticleModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      try {
        _allArticles.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty && result.data.meta!.currentPage < result.data.meta!.lastPage;
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
        emit(ArticleError(error: result.data.msg ?? 'Failed to fetch favorite articles'));
      }
    } else if (result is ResponseError<PaginatedResponse<ArticleModel>>) {
      emit(ArticleError(error: result.message ?? 'Failed to fetch favorite articles'));
    }
  }

  Future<void> getDetailsArticle({required String articleId, required BuildContext context}) async {
    emit(ArticleLoading());

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed('noInternet');
      emit(ArticleError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

    final result = await remoteDataSource.getDetailsArticle(articleId: articleId);
    if (result is Success<ArticleModel>) {
      if (result.data.toString().contains("Unauthorized")) {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      emit(ArticleDetailsSuccess(article: result.data));
    } else if (result is ResponseError<ArticleModel>) {
      emit(ArticleError(error: result.message ?? 'Failed to fetch article details'));
    }
  }

  Future<void> getArticleOfCondition({required String conditionId, required BuildContext context}) async {
    emit(ArticleLoading());

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed('noInternet');
      emit(ArticleError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

    final result = await remoteDataSource.getArticleOfCondition(conditionId: conditionId);
    if (result is Success<ArticleModel>) {
      if (result.data.toString().contains("Unauthorized")) {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      emit(ArticleConditionSuccess(article: result.data));
    } else if (result is ResponseError<ArticleModel>) {
      emit(ArticleError(error: result.message ?? 'Failed to fetch condition article'));
    }
  }

  Future<void> addArticleFavorite({required String articleId, required BuildContext context}) async {
    emit(FavoriteOperationLoading());

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed('noInternet');
      emit(ArticleError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

    final result = await remoteDataSource.addArticleFavorite(articleId: articleId);
    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      emit(FavoriteOperationSuccess(isFavorite: true));
      ShowToast.showToastSuccess(message: result.data.msg ?? 'Added to favorites');
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(ArticleError(error: result.message ?? 'Failed to add favorite'));
    }
  }

  Future<void> removeArticleFavorite({required String articleId, required BuildContext context}) async {
    emit(FavoriteOperationLoading());

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed('noInternet');
      emit(ArticleError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

    final result = await remoteDataSource.removeArticleFavorite(articleId: articleId);
    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      emit(FavoriteOperationSuccess(isFavorite: false));
      ShowToast.showToastSuccess(message: result.data.msg ?? 'Removed from favorites');
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(ArticleError(error: result.message ?? 'Failed to remove favorite'));
    }
  }

  Future<void> generateAiArticle({required String conditionId, required String apiModel, required String language, required BuildContext context}) async {
    emit(ArticleGenerateLoading());

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed('noInternet');
      emit(ArticleError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

    final result = await remoteDataSource.generateAiArticle(conditionId: conditionId, apiModel: apiModel, language: language);

    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      emit(ArticleGenerateSuccess(response: result.data));
      ShowToast.showToastSuccess(message: result.data.msg ?? 'Article generated successfully');
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(ArticleError(error: result.message ?? 'Failed to generate article'));
    }
  }
}
