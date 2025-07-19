import '../../../../base/data/models/code_type_model.dart';

class AddressModel {
  final String? id;
  final String? country;
  final String? city;
  final String? state;
  final String? district;
  final String? line;
  final String? text;
  final String? postalCode;
  final String? startDate;
  final String? endDate;
  final CodeModel? use;
  final CodeModel? type;

  AddressModel({
    required this.id,
    required this.country,
    required this.city,
    required this.state,
    required this.district,
    required this.line,
    required this.text,
    required this.postalCode,
    this.startDate,
    this.endDate,
    this.use,
    this.type,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toString(),
      country: json['country']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      district: json['district']?.toString(),
      line: json['line']?.toString(),
      text: json['text']?.toString(),
      postalCode: json['postal_code']?.toString(),
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),

      use:
          json['use_id'] is Map<String, dynamic>
              ? CodeModel.fromJson(json['use_id'] as Map<String, dynamic>)
              : null,
      type:
          json['type_id'] is Map<String, dynamic>
              ? CodeModel.fromJson(json['type_id'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'country': country,
      'city': city,
      'state': state,
      'district': district,
      'line': line,
      'text': text,
      'postal_code': postalCode,
      'start_date': startDate,
      'end_date': endDate,

      'use_id': use?.id,
      'type_id': type?.id,
    };
  }
}

class AddOrUpdateAddressModel {
  final String? id;
  final String? country;
  final String? city;
  final String? state;
  final String? district;
  final String? line;
  final String? text;
  final String? postalCode;
  final String? startDate;
  final String? endDate;

  final String? useId;
  final String? typeId;

  AddOrUpdateAddressModel({
    this.id,
    required this.country,
    required this.city,
    required this.state,
    required this.district,
    required this.line,
    required this.text,
    required this.postalCode,
    this.startDate,
    this.endDate,
    required this.useId,
    required this.typeId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'country': country,
      'city': city,
      'state': state,
      'district': district,
      'line': line,
      'text': text,
      'postal_code': postalCode,
      'start_date': startDate,
      'end_date': endDate,

      'use_id': useId,
      'type_id': typeId,
    };
  }
}
