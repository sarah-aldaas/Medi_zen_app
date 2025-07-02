import 'package:medizen_app/base/data/models/code_type_model.dart';
import 'package:medizen_app/features/medical_records/encounter/data/models/encounter_model.dart';
import 'package:medizen_app/features/medical_records/service_request/data/models/service_request_model.dart';

class ConditionsModel {
  final String? id;
  final bool? isChronic;
  final String? healthIssue;
  final String? onSetDate;
  final String? onSetAge;
  final String? abatementDate;
  final String? abatementAge;
  final String? recordDate;
  final String? note;
  final String? summary;
  final String? extraNote;
  final CodeModel? clinicalStatus;
  final CodeModel? verificationStatus;
  final CodeModel? bodySite;
  final CodeModel? stage;
  final List<EncounterModel>? encounters;
  final List<ServiceRequestModel>? serviceRequests;

  ConditionsModel({
    this.id,
    this.isChronic,
    this.healthIssue,
    this.onSetDate,
    this.onSetAge,
    this.abatementDate,
    this.abatementAge,
    this.recordDate,
    this.note,
    this.summary,
    this.extraNote,
    this.clinicalStatus,
    this.verificationStatus,
    this.bodySite,
    this.stage,
    this.encounters,
    this.serviceRequests,
  });

  factory ConditionsModel.fromJson(Map<String, dynamic> json) {
    return ConditionsModel(
      id: json['id']?.toString() ?? '',
      // Convert to String and provide default
      isChronic: json['is_chronic'] == 1,
      // Convert 1/0 to boolean
      healthIssue: json['health_issue']?.toString(),
      onSetDate: json['on_set_date']?.toString(),
      onSetAge: json['on_set_age']?.toString(),
      abatementDate: json['abatement_date']?.toString(),
      abatementAge: json['abatement_age']?.toString(),
      recordDate: json['record_date']?.toString(),
      note: json['note']?.toString(),
      summary: json['summary']?.toString(),
      extraNote: json['extra_note']?.toString(),
      clinicalStatus: json['clinical_status'] != null ? CodeModel.fromJson(json['clinical_status']) : null,
      verificationStatus: json['verification_status'] != null ? CodeModel.fromJson(json['verification_status']) : null,
      bodySite: json['body_site'] != null ? CodeModel.fromJson(json['body_site']) : null,
      stage: json['stage'] != null ? CodeModel.fromJson(json['stage']) : null,
      encounters: json['encounters'] is List ? List<EncounterModel>.from(json['encounters'].map((x) => EncounterModel.fromJson(x))) : null,
      serviceRequests:
          json['service_requests'] is List ? List<ServiceRequestModel>.from(json['service_requests'].map((x) => ServiceRequestModel.fromJson(x))) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_chronic':
          isChronic != null
              ? isChronic!
                  ? 1
                  : 0
              : null,
      'health_issue': healthIssue,
      'on_set_date': onSetDate,
      'on_set_age': onSetAge,
      'abatement_date': abatementDate,
      'abatement_age': abatementAge,
      'record_date': recordDate,
      'note': note,
      'summary': summary,
      'extra_note': extraNote,
      'clinical_status': clinicalStatus?.toJson(),
      'verification_status': verificationStatus?.toJson(),
      'body_site': bodySite?.toJson(),
      'stage': stage?.toJson(),
      'encounters': encounters?.map((x) => x.toJson()).toList(),
    };
  }
}
