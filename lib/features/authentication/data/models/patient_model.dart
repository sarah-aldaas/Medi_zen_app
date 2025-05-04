import 'package:equatable/equatable.dart';
import 'package:medizen_app/base/data/models/code_type_model.dart';

class PatientModel extends Equatable {
  final int id;
  final String fName;
  final String lName;
  final String? text;
  final String? family;
  final String? given;
  final String? prefix;
  final String? suffix;
  final String? avatar;
  final String? dateOfBirth;
  final double? height;
  final double? weight;
  final bool? smoker;
  final bool? alcoholDrinker;
  final String? deceasedDate;
  final String email;
  final String? emailVerifiedAt;
  final int active;
  final int genderId;
  final int maritalStatusId;
  final int? bloodId;
  final String createdAt;
  final String updatedAt;
  final CodeModel gender;
  final CodeModel maritalStatus;
  final CodeModel? bloodType;

  const PatientModel({
    required this.id,
    required this.fName,
    required this.lName,
    this.text,
    this.family,
    this.given,
    this.prefix,
    this.suffix,
    this.avatar,
    this.dateOfBirth,
    this.height,
    this.weight,
    this.smoker,
    this.alcoholDrinker,
    this.deceasedDate,
    required this.email,
    this.emailVerifiedAt,
    required this.active,
    required this.genderId,
    required this.maritalStatusId,
    this.bloodId,
    required this.createdAt,
    required this.updatedAt,
    required this.gender,
    required this.maritalStatus,
    this.bloodType,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] as int,
      fName: json['f_name'] as String,
      lName: json['l_name'] as String,
      text: json['text'] as String?,
      family: json['family'] as String?,
      given: json['given'] as String?,
      prefix: json['prefix'] as String?,
      suffix: json['suffix'] as String?,
      avatar: json['avatar'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      smoker: json['smoker'] as bool?,
      alcoholDrinker: json['alcohol_drinker'] as bool?,
      deceasedDate: json['deceased_date'] as String?,
      email: json['email'] as String,
      emailVerifiedAt: json['email_verified_at'] as String?,
      active: json['active'] as int,
      genderId: json['gender_id'] as int,
      maritalStatusId: json['marital_status_id'] as int,
      bloodId: json['blood_id'] as int?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      gender: CodeModel.fromJson(json['gender'] as Map<String, dynamic>),
      maritalStatus: CodeModel.fromJson(json['marital_status'] as Map<String, dynamic>),
      bloodType: json['blood_type'] != null ? CodeModel.fromJson(json['blood_type'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'f_name': fName,
      'l_name': lName,
      'text': text,
      'family': family,
      'given': given,
      'prefix': prefix,
      'suffix': suffix,
      'avatar': avatar,
      'date_of_birth': dateOfBirth,
      'height': height,
      'weight': weight,
      'smoker': smoker,
      'alcohol_drinker': alcoholDrinker,
      'deceased_date': deceasedDate,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'active': active,
      'gender_id': genderId,
      'marital_status_id': maritalStatusId,
      'blood_id': bloodId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'gender': gender.toJson(),
      'marital_status': maritalStatus.toJson(),
      'blood_type': bloodType?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    fName,
    lName,
    text,
    family,
    given,
    prefix,
    suffix,
    avatar,
    dateOfBirth,
    height,
    weight,
    smoker,
    alcoholDrinker,
    deceasedDate,
    email,
    emailVerifiedAt,
    active,
    genderId,
    maritalStatusId,
    bloodId,
    createdAt,
    updatedAt,
    gender,
    maritalStatus,
    bloodType,
  ];
}
