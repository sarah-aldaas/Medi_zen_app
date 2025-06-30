import 'package:medizen_app/base/helpers/enums.dart';
import 'package:medizen_app/base/services/network/network_client.dart';
import 'package:medizen_app/base/services/network/resource.dart';
import 'package:medizen_app/base/services/network/response_handler.dart';
import '../../../../base/data/models/pagination_model.dart';
import '../../../../base/data/models/public_response_model.dart';
import '../end_points/articles_end_points.dart';
import '../model/article_model.dart';

abstract class ArticlesRemoteDataSource {
  Future<Resource<PaginatedResponse<ArticleModel>>> getAllArticles({Map<String, dynamic>? filters, int page = 1, int perPage = 10});

  Future<Resource<PaginatedResponse<ArticleModel>>> getMyFavoriteArticles({Map<String, dynamic>? filters, int page = 1, int perPage = 10});

  Future<Resource<PublicResponseModel>> generateAiArticle({required String conditionId, required String? apiModel, required String language});

  Future<Resource<PublicResponseModel>> addArticleFavorite({required String articleId});

  Future<Resource<PublicResponseModel>> removeArticleFavorite({required String articleId});

  Future<Resource<ArticleResponseModel>> getArticleOfCondition({required String conditionId});

  Future<Resource<ArticleModel>> getDetailsArticle({required String articleId});
}

class ArticlesRemoteDataSourceImpl implements ArticlesRemoteDataSource {
  final NetworkClient networkClient;

  ArticlesRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PublicResponseModel>> addArticleFavorite({required String articleId}) async {
    final response = await networkClient.invoke(ArticlesEndPoints.addArticleFavorite(articleId: articleId), RequestType.post);
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> removeArticleFavorite({required String articleId}) async {
    final response = await networkClient.invoke(ArticlesEndPoints.removeArticleFavorite(articleId: articleId), RequestType.post);
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PaginatedResponse<ArticleModel>>> getAllArticles({Map<String, dynamic>? filters, int page = 1, int perPage = 10}) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(ArticlesEndPoints.getAllArticles(), RequestType.get, queryParameters: params);

    return ResponseHandler<PaginatedResponse<ArticleModel>>(
      response,
    ).processResponse(fromJson: (json) => PaginatedResponse<ArticleModel>.fromJson(json, 'articles', (dataJson) => ArticleModel.fromJson(dataJson)));
  }

  @override
  Future<Resource<PaginatedResponse<ArticleModel>>> getMyFavoriteArticles({Map<String, dynamic>? filters, int page = 1, int perPage = 10}) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(ArticlesEndPoints.getMyFavoriteArticles(), RequestType.get, queryParameters: params);

    return ResponseHandler<PaginatedResponse<ArticleModel>>(
      response,
    ).processResponse(fromJson: (json) => PaginatedResponse<ArticleModel>.fromJson(json, 'articles', (dataJson) => ArticleModel.fromJson(dataJson)));
  }

  @override
  Future<Resource<ArticleModel>> getDetailsArticle({required String articleId}) async {
    final response = await networkClient.invoke(ArticlesEndPoints.getDetailsArticle(articleId: articleId), RequestType.get);
    return ResponseHandler<ArticleModel>(response).processResponse(fromJson: (json) => ArticleModel.fromJson(json['article']));
  }

  @override
  Future<Resource<ArticleResponseModel>> getArticleOfCondition({required String conditionId}) async {
    final response = await networkClient.invoke(ArticlesEndPoints.getArticleOfCondition(conditionId: conditionId), RequestType.get);
    return ResponseHandler<ArticleResponseModel>(response).processResponse(fromJson: (json) => ArticleResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> generateAiArticle({required String conditionId, required String? apiModel, required String language}) async {
    final params = {'language': language.toString(), if (apiModel != null) 'model': apiModel};

    final response = await networkClient.invoke(ArticlesEndPoints.generateAiArticle(conditionId: conditionId), RequestType.get, queryParameters: params);

    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }
}
