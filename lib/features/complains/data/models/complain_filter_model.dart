import 'package:intl/intl.dart';

class ComplainFilterModel {
  final String? searchQuery;
  final String? statusId;
  final String? typeId;
  final bool? assignedToAdmin;
  final String? appointmentId;
  final DateTime? createdFrom;
  final DateTime? createdTo;

  ComplainFilterModel({
    this.searchQuery,
    this.statusId,
    this.typeId,
    this.assignedToAdmin,
    this.appointmentId,
    this.createdFrom,
    this.createdTo,
  });

  Map<String, dynamic> toJson() {
    final dateFormat = DateFormat('yyyy-MM-dd');
    return {
      if (searchQuery != null && searchQuery!.isNotEmpty)
        'search_query': searchQuery,
      if (statusId != null) 'status_id': statusId,
      if (typeId != null) 'type_id': typeId,
      if (assignedToAdmin != null) 'assigned_to_admin': assignedToAdmin! ? 1 : 0,
      if (appointmentId != null) 'appointment_id': appointmentId,
      if (createdFrom != null) 'created_from': dateFormat.format(createdFrom!),
      if (createdTo != null) 'created_to': dateFormat.format(createdTo!),
    };
  }

  ComplainFilterModel copyWith({
    String? searchQuery,
    String? statusId,
    String? typeId,
    bool? assignedToAdmin,
    String? appointmentId,
    DateTime? createdFrom,
    DateTime? createdTo,
  }) {
    return ComplainFilterModel(
      searchQuery: searchQuery ?? this.searchQuery,
      statusId: statusId ?? this.statusId,
      typeId: typeId ?? this.typeId,
      assignedToAdmin: assignedToAdmin ?? this.assignedToAdmin,
      appointmentId: appointmentId ?? this.appointmentId,
      createdFrom: createdFrom ?? this.createdFrom,
      createdTo: createdTo ?? this.createdTo,
    );
  }
}