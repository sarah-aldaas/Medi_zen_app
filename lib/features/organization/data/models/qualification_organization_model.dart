class QualificationsOrganizationModel{
  final String? id;
  final String? issuer;
  final String? startDate;
  final String? endDate;
  final String? pdf;

  QualificationsOrganizationModel({
    required this.id,
    required this.issuer,
    required this.startDate,
    required this.endDate,
    required this.pdf,
  });

  factory QualificationsOrganizationModel.fromJson(Map<String, dynamic> json) {
    return QualificationsOrganizationModel(
      id: json['id'].toString(),
      issuer: json['issuer'].toString(),
      pdf: json['pdf'].toString(),
      startDate: json['start_date'].toString(),
      endDate: json['end_date'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_date': startDate,
      'end_date': endDate,
      'pdf': pdf,
      'issuer': issuer,
    };
  }
}