class EligibilityModel {
  final int id;
  final String code;
  final String display;
  final String description;

  EligibilityModel({
    required this.id,
    required this.code,
    required this.display,
    required this.description,
  });

  factory EligibilityModel.fromJson(Map<String, dynamic> json) {
    return EligibilityModel(
      id: json['id'] as int,
      code: json['code'] as String,
      display: json['display'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'display': display,
      'description': description,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is EligibilityModel &&
              id == other.id &&
              code == other.code &&
              display == other.display &&
              description == other.description;

  @override
  int get hashCode => Object.hash(id, code, display, description);
}