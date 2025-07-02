class ArticlesEndPoints {
  static String getAllArticles() => "/patient/articles";

  static String generateAiArticle({required String conditionId}) => "/patient/conditions/$conditionId/generate-ai-article";

  static String getArticleOfCondition({required String conditionId}) => "/patient/conditions/$conditionId/articles";

  static String getDetailsArticle({required String articleId}) => "/patient/articles/$articleId";

  static String addArticleFavorite({required String articleId}) => "/patient/articles/$articleId/add-to-favorite-list";

  static String removeArticleFavorite({required String articleId}) => "/patient/articles/$articleId/remove-from-favorite-list";

  static String getMyFavoriteArticles() => "/patient/my-favorite-articles";
}
