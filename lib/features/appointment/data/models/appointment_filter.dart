import 'package:intl/intl.dart';

class AppointmentFilter {
  final String? type;
  final int? typeId;
  final List<int>? typeIds;
  final int? statusId;
  final List<int>? statusIds;
  final int? doctorId;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? cancellationDate;
  final int? createdByPractitioner;
  final int? clinicId;
  final String? sort;

  AppointmentFilter({
    this.type,
    this.typeId,
    this.typeIds,
    this.statusId,
    this.statusIds,
    this.doctorId,
    this.startDate,
    this.endDate,
    this.cancellationDate,
    this.createdByPractitioner,
    this.clinicId,
    this.sort,
  });

  Map<String, dynamic> toJson() {
    return {
      if (type != null) 'type': type,
      if (typeId != null) 'type_id': typeId,
      if (typeIds != null && typeIds!.isNotEmpty) 'type_ids': typeIds!.join(','),
      if (statusId != null) 'status_id': statusId,
      if (statusIds != null && statusIds!.isNotEmpty) 'status_ids': statusIds!.join(','),
      if (doctorId != null) 'doctor_id': doctorId,
      if (startDate != null) 'start_date': DateFormat('yyyy-MM-dd').format(startDate!),
      if (endDate != null) 'end_date': DateFormat('yyyy-MM-dd').format(endDate!),
      if (cancellationDate != null) 'cancellation_date': DateFormat('yyyy-MM-dd').format(cancellationDate!),
      if (createdByPractitioner != null) 'created_by_practitioner': createdByPractitioner,
      if (clinicId != null) 'clinic_id': clinicId,
      if (sort != null) 'sort': sort,
    };
  }

  AppointmentFilter copyWith({
    String? type,
    int? typeId,
    List<int>? typeIds,
    int? statusId,
    List<int>? statusIds,
    int? doctorId,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? cancellationDate,
    int? createdByPractitioner,
    int? clinicId,
    String? sort,
  }) {
    return AppointmentFilter(
      type: type ?? this.type,
      typeId: typeId ?? this.typeId,
      typeIds: typeIds ?? this.typeIds,
      statusId: statusId ?? this.statusId,
      statusIds: statusIds ?? this.statusIds,
      doctorId: doctorId ?? this.doctorId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      cancellationDate: cancellationDate ?? this.cancellationDate,
      createdByPractitioner: createdByPractitioner ?? this.createdByPractitioner,
      clinicId: clinicId ?? this.clinicId,
      sort: sort ?? this.sort,
    );
  }
}

