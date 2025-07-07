import '../../../../base/data/models/code_type_model.dart';

class QualificationModel {
  final int id;
  final String issuer;
  final String startDate;
  final String? endDate;
  final String? pdf;
  final CodeModel? type;

  QualificationModel({
    required this.id,
    required this.issuer,
    required this.startDate,
    this.endDate,
    this.pdf,
    required this.type,
  });

  factory QualificationModel.fromJson(Map<String, dynamic> json) {
    return QualificationModel(
      id: json['id'] as int,
      issuer: json['issuer'] as String,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String?,
      pdf: json['pdf'] as String?,
      type:json['type'] !=null? CodeModel.fromJson(json['type'] as Map<String, dynamic>):null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'issuer': issuer,
      'start_date': startDate,
      'end_date': endDate,
      'pdf': pdf,
      'type': type!.toJson(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QualificationModel &&
          id == other.id &&
          issuer == other.issuer &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          pdf == other.pdf &&
          type == other.type;

  @override
  int get hashCode => Object.hash(id, issuer, startDate, endDate, pdf, type);
}
