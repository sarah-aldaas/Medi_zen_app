class CodeTypeModel {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  CodeTypeModel({required this.id, required this.name, required this.createdAt, required this.updatedAt});

  factory CodeTypeModel.fromJson(Map<String, dynamic> json) {
    return CodeTypeModel(id: json['id'], name: json['name'], createdAt: DateTime.parse(json['created_at']), updatedAt: DateTime.parse(json['updated_at']));
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'created_at': createdAt.toIso8601String(), 'updated_at': updatedAt.toIso8601String()};
  }
}

// models/code_model.dart
class CodeModel {
  final int id;
  final String code;
  final String display;
  final String description;
  final int codeTypeId;
  final DateTime createdAt;
  final DateTime updatedAt;

  CodeModel({
    required this.id,
    required this.code,
    required this.display,
    required this.description,
    required this.codeTypeId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CodeModel.fromJson(Map<String, dynamic> json) {
    return CodeModel(
      id: json['id'],
      code: json['code'],
      display: json['display'],
      description: json['description'],
      codeTypeId: json['code_type_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'display': display,
      'description': description,
      'code_type_id': codeTypeId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
