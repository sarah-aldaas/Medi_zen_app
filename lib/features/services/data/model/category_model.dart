class CategoryModel {
  final int id;
  final String code;
  final String display;
  final String description;

  CategoryModel({
    required this.id,
    required this.code,
    required this.display,
    required this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
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
          other is CategoryModel &&
              id == other.id &&
              code == other.code &&
              display == other.display &&
              description == other.description;

  @override
  int get hashCode => Object.hash(id, code, display, description);
}
