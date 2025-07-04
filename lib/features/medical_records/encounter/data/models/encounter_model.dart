import 'package:medizen_app/base/data/models/code_type_model.dart';
import 'package:medizen_app/features/appointment/data/models/appointment_model.dart';
import 'package:medizen_app/features/services/data/model/health_care_services_model.dart';

import '../../../../invoice/data/models/invoice_model.dart';

class EncounterModel {
  final String? id;
  final String? reason;
  final String? actualStartDate;
  final String? actualEndDate;
  final String? specialArrangement;
  final AppointmentModel? appointment;
  final CodeModel? type;
  final CodeModel? status;
  final List<HealthCareServiceModel>? healthCareServices;
  final InvoiceModel? invoice;

  EncounterModel({
    required this.id,
    required this.reason,
    required this.actualStartDate,
    required this.actualEndDate,
    required this.specialArrangement,
    required this.appointment,
    required this.type,
    required this.status,
    required this.healthCareServices,
    required this.invoice,
  });

  factory EncounterModel.fromJson(Map<String, dynamic> json) {
    return EncounterModel(
      id: json['id'].toString(),
      reason: json['reason'].toString(),
      actualStartDate: json['actual_start_date'].toString(),
      actualEndDate: json['actual_end_date'].toString(),
      specialArrangement: json['special_arrangement'].toString(),
      appointment:json['appointment']!=null? AppointmentModel.fromJson(json['appointment']):null,
      type:json['type']!=null? CodeModel.fromJson(json['type']):null,
      status: json['status']!=null?CodeModel.fromJson(json['status']):null,
      invoice: json['invoice']!=null?InvoiceModel.fromJson(json['invoice']):null,
      healthCareServices:json['health_care_services']!=null? List<HealthCareServiceModel>.from(
          json['health_care_services'].map((x) => HealthCareServiceModel.fromJson(x))):[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reason': reason,
      'actual_start_date': actualStartDate,
      'actual_end_date': actualEndDate,
      'special_arrangement': specialArrangement,
      'appointment': appointment!.toJson(),
      'type': type!.toJson(),
      'status': status!.toJson(),
      'health_care_services': healthCareServices!.map((x) => x.toJson()).toList(),
    };
  }
}

