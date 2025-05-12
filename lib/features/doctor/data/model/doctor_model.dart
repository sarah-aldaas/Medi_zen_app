import 'package:medizen_app/base/data/models/code_type_model.dart';
import 'package:medizen_app/features/doctor/data/model/qualification_model.dart';

import 'communication_model.dart';

class DoctorModel {
  final int id;
  final String fName;
  final String lName;
  final String text;
  final String family;
  final String given;
  final String prefix;
  final String suffix;
  final String avatar;
  final String address;
  final String dateOfBirth;
  final String? deceasedDate;
  final String email;
  final String? emailVerifiedAt;
  final bool active;
  final CodeModel gender;
  final List<CodeModel> telecoms;
  final List<CommunicationModel> communications;
  final List<QualificationModel> qualifications;

  DoctorModel({
    required this.id,
    required this.fName,
    required this.lName,
    required this.text,
    required this.family,
    required this.given,
    required this.prefix,
    required this.suffix,
    required this.avatar,
    required this.address,
    required this.dateOfBirth,
    this.deceasedDate,
    required this.email,
    this.emailVerifiedAt,
    required this.active,
    required this.gender,
    required this.telecoms,
    required this.communications,
    required this.qualifications,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] as int,
      fName: json['f_name'] as String,
      lName: json['l_name'] as String,
      text: json['text'] as String,
      family: json['family'] as String,
      given: json['given'] as String,
      prefix: json['prefix'] as String,
      suffix: json['suffix'] as String,
      avatar: json['avatar'] as String,
      address: json['address'] as String,
      dateOfBirth: json['date_of_birth'] as String,
      deceasedDate: json['deceased_date'] as String?,
      email: json['email'] as String,
      emailVerifiedAt: json['email_verified_at'] as String?,
      active: (json['active'] as int) == 1,
      gender: CodeModel.fromJson(json['gender'] as Map<String, dynamic>),
      telecoms: (json['telecoms'] as List).map((item) => CodeModel.fromJson(item as Map<String, dynamic>)).toList(),
      communications: (json['communications'] as List).map((item) => CommunicationModel.fromJson(item as Map<String, dynamic>)).toList(),
      qualifications: (json['qualifications'] as List).map((item) => QualificationModel.fromJson(item as Map<String, dynamic>)).toList(),
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
      'address': address,
      'date_of_birth': dateOfBirth,
      'deceased_date': deceasedDate,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'active': active ? 1 : 0,
      'gender': gender.toJson(),
      'telecoms': telecoms.map((t) => t.toJson()).toList(),
      'communications': communications.map((c) => c.toJson()).toList(),
      'qualifications': qualifications.map((q) => q.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoctorModel &&
          id == other.id &&
          fName == other.fName &&
          lName == other.lName &&
          text == other.text &&
          family == other.family &&
          given == other.given &&
          prefix == other.prefix &&
          suffix == other.suffix &&
          avatar == other.avatar &&
          address == other.address &&
          dateOfBirth == other.dateOfBirth &&
          deceasedDate == other.deceasedDate &&
          email == other.email &&
          emailVerifiedAt == other.emailVerifiedAt &&
          active == other.active &&
          gender == other.gender &&
          telecoms == other.telecoms &&
          communications == other.communications &&
          qualifications == other.qualifications;

  @override
  int get hashCode => Object.hash(
    id,
    fName,
    lName,
    text,
    family,
    given,
    prefix,
    suffix,
    avatar,
    address,
    dateOfBirth,
    deceasedDate,
    email,
    emailVerifiedAt,
    active,
    gender,
    telecoms,
    communications,
    qualifications,
  );
}
