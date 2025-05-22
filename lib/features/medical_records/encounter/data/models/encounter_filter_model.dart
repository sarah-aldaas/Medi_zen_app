class EncounterFilterModel {
  final String? searchQuery;
  final int? statusId;
  final int? typeId;
  final int? appointmentId;
  final DateTime? minStartDate;
  final DateTime? maxStartDate;
  final int? paginationCount;
  final String? key;

  EncounterFilterModel({
    this.searchQuery,
    this.statusId,
    this.typeId,
    this.appointmentId,
    this.minStartDate,
    this.maxStartDate,
    this.paginationCount,
    this.key,
  });

  Map<String, dynamic> toJson() {
    return {
      'search_query': searchQuery,
      'status_id': statusId,
      'type_id': typeId,
      'appointment_id': appointmentId,
      'min_start_date': minStartDate?.toIso8601String(),
      'max_start_date': maxStartDate?.toIso8601String(),
      'pagination_count': paginationCount,
      'key': key,
    };
  }

  EncounterFilterModel copyWith({
    String? searchQuery,
    int? statusId,
    int? typeId,
    int? appointmentId,
    DateTime? minStartDate,
    DateTime? maxStartDate,
    int? paginationCount,
    String? key,
  }) {
    return EncounterFilterModel(
      searchQuery: searchQuery ?? this.searchQuery,
      statusId: statusId ?? this.statusId,
      typeId: typeId ?? this.typeId,
      appointmentId: appointmentId ?? this.appointmentId,
      minStartDate: minStartDate ?? this.minStartDate,
      maxStartDate: maxStartDate ?? this.maxStartDate,
      paginationCount: paginationCount ?? this.paginationCount,
      key: key ?? this.key,
    );
  }
}