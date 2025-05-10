class Clinic {
  final int id;
  final String name;
  final String description;
  final String photo;
  final bool active;

  Clinic({
    required this.id,
    required this.name,
    required this.description,
    required this.photo,
    required this.active,
  });

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      photo: json['photo'],
      active: json['active'] == 1,
    );
  }
}
