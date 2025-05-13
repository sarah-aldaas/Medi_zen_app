
import 'package:medizen_app/base/data/models/code_type_model.dart';

import '../../../authentication/data/models/patient_model.dart';
import '../../../doctor/data/model/doctor_model.dart';

class AppointmentModel {
  final int id;
  final String reason;
  final String description;
  final String startDate;
  final String endDate;
  final int minutesDuration;
  final String? note;
  final String? cancellationDate;
  final String? cancellationReason;
  final CodeModel type;
  final CodeModel status;
  final DoctorModel doctor;
  final PatientModel patient;
  final dynamic previousAppointment;
  final dynamic createdByPractitioner;

  AppointmentModel({
    required this.id,
    required this.reason,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.minutesDuration,
    this.note,
    this.cancellationDate,
    this.cancellationReason,
    required this.type,
    required this.status,
    required this.doctor,
    required this.patient,
    this.previousAppointment,
    this.createdByPractitioner,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as int,
      reason: json['reason'] as String,
      description: json['description'] as String,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      minutesDuration: json['minutes_duration'] as int,
      note: json['note'] as String?,
      cancellationDate: json['cancellation_date'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      type: CodeModel.fromJson(json['type'] as Map<String, dynamic>),
      status: CodeModel.fromJson(json['status'] as Map<String, dynamic>),
      doctor: DoctorModel.fromJson(json['doctor'] as Map<String, dynamic>),
      patient: PatientModel.fromJson(json['patient'] as Map<String, dynamic>),
      previousAppointment: json['previous_appointment'],
      createdByPractitioner: json['created_by_practitioner'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reason': reason,
      'description': description,
      'start_date': startDate,
      'end_date': endDate,
      'minutes_duration': minutesDuration,
      'note': note,
      'cancellation_date': cancellationDate,
      'cancellation_reason': cancellationReason,
      'type': type.toJson(),
      'status': status.toJson(),
      'doctor': doctor.toJson(),
      'patient': patient.toJson(),
      'previous_appointment': previousAppointment,
      'created_by_practitioner': createdByPractitioner,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AppointmentModel &&
              id == other.id &&
              reason == other.reason &&
              description == other.description &&
              startDate == other.startDate &&
              endDate == other.endDate &&
              minutesDuration == other.minutesDuration &&
              note == other.note &&
              cancellationDate == other.cancellationDate &&
              cancellationReason == other.cancellationReason &&
              type == other.type &&
              status == other.status &&
              doctor == other.doctor &&
              patient == other.patient &&
              previousAppointment == other.previousAppointment &&
              createdByPractitioner == other.createdByPractitioner;

  @override
  int get hashCode => Object.hash(
    id,
    reason,
    description,
    startDate,
    endDate,
    minutesDuration,
    note,
    cancellationDate,
    cancellationReason,
    type,
    status,
    doctor,
    patient,
    previousAppointment,
    createdByPractitioner,
  );
}