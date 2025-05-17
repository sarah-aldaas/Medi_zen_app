class AppointmentCreateModel {
  final String reason;
  final String description;
  final String? note;
  final int doctorId;
  final int patientId;
  final dynamic previousAppointment;
  final int slotId;

  AppointmentCreateModel({
    required this.reason,
    required this.description,
    this.note,
    required this.doctorId,
    required this.patientId,
    this.previousAppointment,
    required this.slotId,
  });

  factory AppointmentCreateModel.fromJson(Map<String, dynamic> json) {
    return AppointmentCreateModel(
      reason: json['reason'] as String,
      description: json['description'] as String,
      note: json['note'] as String?,
      doctorId: json['doctor_id'] as int,
      patientId: json['patient_id'] as int,
      previousAppointment: json['previous_appointment'],
      slotId: json['slot_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reason': reason,
      'description': description,
      'note': note,
      'doctor_id': doctorId,
      'patient_id': patientId,
      'previous_appointment': previousAppointment,
      'slot_id': slotId,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AppointmentCreateModel &&
              reason == other.reason &&
              description == other.description &&
              note == other.note &&
              doctorId == other.doctorId &&
              patientId == other.patientId &&
              previousAppointment == other.previousAppointment &&
              slotId == other.slotId;

  @override
  int get hashCode => Object.hash(
    reason,
    description,
    note,
    doctorId,
    patientId,
    previousAppointment,
    slotId,
  );
}