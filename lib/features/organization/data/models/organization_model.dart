class OrganizationModel {
  final String id;
  final String name;
  final String aliase;
  final String description;
  final String type;
  final String phone;
  final String address;
  final String beginOfWork;
  final String endOfWork;
  final bool active;

  OrganizationModel({
    required this.id,
    required this.name,
    required this.aliase,
    required this.description,
    required this.type,
    required this.phone,
    required this.address,
    required this.beginOfWork,
    required this.endOfWork,
    required this.active,
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      id: json['id'].toString(),
      name: json['name'].toString(),
      aliase: json['aliase'].toString(),
      description: json['description'].toString(),
      type: json['type'].toString(),
      phone: json['phone'].toString(),
      address: json['address'].toString(),
      beginOfWork: json['begin_of_work'].toString(),
      endOfWork: json['end_of_work'].toString(),
      active: json['active'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'aliase': aliase,
      'description': description,
      'type': type,
      'phone': phone,
      'address': address,
      'begin_of_work': beginOfWork,
      'end_of_work': endOfWork,
      'active': active ? 1 : 0,
    };
  }
}