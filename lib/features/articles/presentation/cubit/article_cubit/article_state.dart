part of 'article_cubit.dart';

@immutable
sealed class ArticleState {
  const ArticleState();
}

final class ArticleInitial extends ArticleState {}

class ArticleLoading extends ArticleState {
  final bool isLoadMore;

  const ArticleLoading({this.isLoadMore = false});

  @override
  List<Object?> get props => [isLoadMore];
}

class ArticleGenerateLoading extends ArticleState {}

class ArticleSuccess extends ArticleState {
  final bool hasMore;
  final PaginatedResponse<ArticleModel> paginatedResponse;

  const ArticleSuccess({
    required this.paginatedResponse,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [hasMore, paginatedResponse];
}

class ArticleDetailsSuccess extends ArticleState {
  final ArticleModel article;

  const ArticleDetailsSuccess({required this.article});

  @override
  List<Object?> get props => [article];
}

class ArticleConditionSuccess extends ArticleState {
  final ArticleModel? article;

  const ArticleConditionSuccess({required this.article});

  @override
  List<Object?> get props => [article];
}

class ArticleGenerateSuccess extends ArticleState {
  final PublicResponseModel response;

  const ArticleGenerateSuccess({required this.response});

  @override
  List<Object?> get props => [response];
}

class ArticleGenerateProgress extends ArticleState {
  final double progress;
  final String? message;

  const ArticleGenerateProgress({this.progress = 0, this.message});

  @override
  List<Object?> get props => [progress, message];
}

class ArticleError extends ArticleState {
  final String error;

  const ArticleError({required this.error});

  @override
  List<Object?> get props => [error];
}

class FavoriteOperationLoading extends ArticleState {}

class FavoriteOperationSuccess extends ArticleState {
  final bool isFavorite;

  const FavoriteOperationSuccess({required this.isFavorite});

  @override
  List<Object?> get props => [isFavorite];
}
