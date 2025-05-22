class ReactionFilterModel {
  final String? searchQuery;
  final int? severityId;
  final int? exposureRouteId;
  final int? paginationCount;
  final String? key;

  ReactionFilterModel({
    this.searchQuery,
    this.severityId,
    this.exposureRouteId,
    this.paginationCount,
    this.key,
  });

  Map<String, dynamic> toJson() {
    return {
      'search_query': searchQuery,
      'severity_id': severityId,
      'exposure_route_id': exposureRouteId,
      'pagination_count': paginationCount,
      'key': key,
    };
  }

  ReactionFilterModel copyWith({
    String? searchQuery,
    int? severityId,
    int? exposureRouteId,
    int? paginationCount,
    String? key,
  }) {
    return ReactionFilterModel(
      searchQuery: searchQuery ?? this.searchQuery,
      severityId: severityId ?? this.severityId,
      exposureRouteId: exposureRouteId ?? this.exposureRouteId,
      paginationCount: paginationCount ?? this.paginationCount,
      key: key ?? this.key,
    );
  }

  @override
  String toString() {
    return 'ReactionFilterModel{searchQuery: $searchQuery, severityId: $severityId, exposureRouteId: $exposureRouteId, paginationCount: $paginationCount, key: $key}';
  }
}