class ClinicModel {
  final int id;
  final String name;
  final String description;
  final String photo;
  final bool active;
  final List<dynamic>? healthCareServices;

  ClinicModel({
    required this.id,
    required this.name,
    required this.description,
    required this.photo,
    required this.active,
    this.healthCareServices,
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    return ClinicModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      photo: json['photo'] as String,
      active: (json['active'] as int) == 1,
      healthCareServices: json['healthCareServices'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'photo': photo,
      'active': active ? 1 : 0,
      'healthCareServices': healthCareServices,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ClinicModel &&
              id == other.id &&
              name == other.name &&
              description == other.description &&
              photo == other.photo &&
              active == other.active &&
              healthCareServices == other.healthCareServices;

  @override
  int get hashCode => Object.hash(id, name, description, photo, active, healthCareServices);
}