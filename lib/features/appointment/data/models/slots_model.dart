import 'package:medizen_app/base/data/models/code_type_model.dart';
import 'package:medizen_app/features/appointment/data/models/schedule_model.dart';

class SlotModel {
  final int id;
  final String startDate;
  final String endDate;
  final String? comment;
  final ScheduleModel schedule;
  final CodeModel status;

  SlotModel({
    required this.id,
    required this.startDate,
    required this.endDate,
    this.comment,
    required this.schedule,
    required this.status,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      id: json['id'] as int,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      comment: json['comment'] as String?,
      schedule: ScheduleModel.fromJson(json['schedule'] as Map<String, dynamic>),
      status: CodeModel.fromJson(json['status'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_date': startDate,
      'end_date': endDate,
      'comment': comment,
      'schedule': schedule.toJson(),
      'status': status.toJson(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SlotModel &&
              id == other.id &&
              startDate == other.startDate &&
              endDate == other.endDate &&
              comment == other.comment &&
              schedule == other.schedule &&
              status == other.status;

  @override
  int get hashCode => Object.hash(id, startDate, endDate, comment, schedule, status);
}