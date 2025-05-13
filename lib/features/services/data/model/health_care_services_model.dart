import '../../../clinics/data/models/clinic_model.dart';
import 'category_model.dart';
import 'eligibility_model.dart';

class HealthCareServiceModel {
  final int id;
  final String name;
  final String comment;
  final String? extraDetails;
  final String? photo;
  final bool appointmentRequired;
  final double price;
  final bool active;
  final CategoryModel category;
  final ClinicModel clinic;
  final List<EligibilityModel> eligibilities;

  HealthCareServiceModel({
    required this.id,
    required this.name,
    required this.comment,
    this.extraDetails,
    this.photo,
    required this.appointmentRequired,
    required this.price,
    required this.active,
    required this.category,
    required this.clinic,
    required this.eligibilities,
  });

  factory HealthCareServiceModel.fromJson(Map<String, dynamic> json) {
    return HealthCareServiceModel(
      id: json['id'] as int,
      name: json['name'] as String,
      comment: json['comment'] as String,
      extraDetails: json['extra_details'] as String?,
      photo: json['photo'] as String?,
      appointmentRequired: (json['appointmentRequired'] as int) == 1,
      price: double.parse(json['price'] as String),
      active: (json['active'] as int) == 1,
      category: CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
      clinic: ClinicModel.fromJson(json['clinic'] as Map<String, dynamic>),
      eligibilities: (json['eligibilities'] as List)
          .map((item) => EligibilityModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'comment': comment,
      'extra_details': extraDetails,
      'photo': photo,
      'appointmentRequired': appointmentRequired ? 1 : 0,
      'price': price.toStringAsFixed(2),
      'active': active ? 1 : 0,
      'category': category.toJson(),
      'clinic': clinic.toJson(),
      'eligibilities': eligibilities.map((e) => e.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is HealthCareServiceModel &&
              id == other.id &&
              name == other.name &&
              comment == other.comment &&
              extraDetails == other.extraDetails &&
              photo == other.photo &&
              appointmentRequired == other.appointmentRequired &&
              price == other.price &&
              active == other.active &&
              category == other.category &&
              clinic == other.clinic &&
              eligibilities == other.eligibilities;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    comment,
    extraDetails,
    photo,
    appointmentRequired,
    price,
    active,
    category,
    clinic,
    eligibilities,
  );
}


