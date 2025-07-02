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
    final map = <String, dynamic>{};

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      map['search_query'] = searchQuery;
    }

    if (statusId != null) {
      map['status_id'] = statusId;
    }

    if (typeId != null) {
      map['type_id'] = typeId;
    }

    if (appointmentId != null) {
      map['appointment_id'] = appointmentId;
    }

    if (minStartDate != null) {
      map['min_start_date'] = minStartDate!.toIso8601String();
    }

    if (maxStartDate != null) {
      map['max_start_date'] = maxStartDate!.toIso8601String();
    }

    if (key != null && key!.isNotEmpty) {
      map['key'] = key;
    }

    return map;
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