import 'package:medizen_app/base/data/models/code_type_model.dart';
import 'package:medizen_app/features/medical_records/observation/data/models/laboratory_model.dart';
import 'package:medizen_app/features/medical_records/series/data/models/series_model.dart';
import 'package:medizen_app/features/medical_records/service_request/data/models/service_request_model.dart';

class ImagingStudyModel {
  final String? id;
  final String? title;
  final String? description;
  final DateTime? started;
  final String? cancelledReason;
  final CodeModel? status;
  final CodeModel? modality;
  final LaboratoryModel? radiology;
  final ServiceRequestModel? serviceRequest;
  final List<SeriesModel>? series;

  ImagingStudyModel({this.id, this.title, this.description, this.started, this.cancelledReason, this.status, this.modality,this.radiology,this.serviceRequest,this.series});

  factory ImagingStudyModel.fromJson(Map<String, dynamic> json) {
    return ImagingStudyModel(
      id: json['id'].toString(),
      title: json['title'].toString(),
      description: json['description'].toString(),
      started: json['started'] != null ? DateTime.parse(json['started']) : null,
      cancelledReason: json['cancelled_reason'],
      status:json['status']!=null? CodeModel.fromJson(json['status']):null,
      modality:json['modality']!=null? CodeModel.fromJson(json['modality']):null,
      serviceRequest:json['service_request']!=null? ServiceRequestModel.fromJson(json['service_request']):null,
      radiology:json['radiology']!=null? LaboratoryModel.fromJson(json['radiology']):null,
      series:(json['series'] as List<dynamic>?)?.map((item) => SeriesModel.fromJson(item as Map<String, dynamic>)).toList() ?? []
    );
  }
}
