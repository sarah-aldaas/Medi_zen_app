import 'package:medizen_app/features/appointment/data/models/repeat_model.dart';

import '../../../doctor/data/model/doctor_model.dart';

class ScheduleModel {
  final int id;
  final String name;
  final bool active;
  final String planningHorizonStart;
  final String planningHorizonEnd;
  final RepeatModel repeat;
  final String? comment;
  final DoctorModel practitioner;

  ScheduleModel({
    required this.id,
    required this.name,
    required this.active,
    required this.planningHorizonStart,
    required this.planningHorizonEnd,
    required this.repeat,
    this.comment,
    required this.practitioner,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] as int,
      name: json['name'] as String,
      active: (json['active'] as int) == 1,
      planningHorizonStart: json['planning_horizon_start'] as String,
      planningHorizonEnd: json['planning_horizon_end'] as String,
      repeat: RepeatModel.fromJson(json['repeat'] as Map<String, dynamic>),
      comment: json['comment'] as String?,
      practitioner: DoctorModel.fromJson(json['practitioner'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'active': active ? 1 : 0,
      'planning_horizon_start': planningHorizonStart,
      'planning_horizon_end': planningHorizonEnd,
      'repeat': repeat.toJson(),
      'comment': comment,
      'practitioner': practitioner.toJson(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ScheduleModel &&
              id == other.id &&
              name == other.name &&
              active == other.active &&
              planningHorizonStart == other.planningHorizonStart &&
              planningHorizonEnd == other.planningHorizonEnd &&
              repeat == other.repeat &&
              comment == other.comment &&
              practitioner == other.practitioner;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    active,
    planningHorizonStart,
    planningHorizonEnd,
    repeat,
    comment,
    practitioner,
  );
}
