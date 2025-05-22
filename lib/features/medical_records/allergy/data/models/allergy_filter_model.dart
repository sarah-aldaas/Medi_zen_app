class AllergyFilterModel {
  final String? searchQuery;
  final int? isDiscoveredDuringEncounter;
  final int? typeId;
  final int? clinicalStatusId;
  final int? verificationStatusId;
  final int? categoryId;
  final int? criticalityId;
  final String? sort; // 'asc' or 'desc'
  final int? paginationCount;

  AllergyFilterModel({
    this.searchQuery,
    this.isDiscoveredDuringEncounter,
    this.typeId,
    this.clinicalStatusId,
    this.verificationStatusId,
    this.categoryId,
    this.criticalityId,
    this.sort,
    this.paginationCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'search_query': searchQuery,
      'is_discovered_during_encounter': isDiscoveredDuringEncounter,
      'type_id': typeId,
      'clinical_status_id': clinicalStatusId,
      'verification_status_id': verificationStatusId,
      'category_id': categoryId,
      'criticality_id': criticalityId,
      'sort': sort,
      'pagination_count': paginationCount,
    };
  }

  AllergyFilterModel copyWith({
    String? searchQuery,
    int? isDiscoveredDuringEncounter,
    int? typeId,
    int? clinicalStatusId,
    int? verificationStatusId,
    int? categoryId,
    int? criticalityId,
    String? sort,
    int? paginationCount,
  }) {
    return AllergyFilterModel(
      searchQuery: searchQuery ?? this.searchQuery,
      isDiscoveredDuringEncounter: isDiscoveredDuringEncounter ?? this.isDiscoveredDuringEncounter,
      typeId: typeId ?? this.typeId,
      clinicalStatusId: clinicalStatusId ?? this.clinicalStatusId,
      verificationStatusId: verificationStatusId ?? this.verificationStatusId,
      categoryId: categoryId ?? this.categoryId,
      criticalityId: criticalityId ?? this.criticalityId,
      sort: sort ?? this.sort,
      paginationCount: paginationCount ?? this.paginationCount,
    );
  }

  @override
  String toString() {
    return 'AllergyFilterModel{'
        'searchQuery: $searchQuery, '
        'isDiscoveredDuringEncounter: $isDiscoveredDuringEncounter, '
        'typeId: $typeId, '
        'clinicalStatusId: $clinicalStatusId, '
        'verificationStatusId: $verificationStatusId, '
        'categoryId: $categoryId, '
        'criticalityId: $criticalityId, '
        'sort: $sort, '
        'paginationCount: $paginationCount}';
  }
}