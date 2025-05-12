import 'dart:io';
import 'package:equatable/equatable.dart';

class UpdateProfileRequestModel extends Equatable {
  final String? fName;
  final String? lName;
  final File? avatar;
  final String? genderId;
  final String? maritalStatusId;

  const UpdateProfileRequestModel({
    this.fName,
    this.lName,
    this.avatar,
    this.genderId,
    this.maritalStatusId,
  });

  factory UpdateProfileRequestModel.fromJson(Map<String, dynamic> json) {
    return UpdateProfileRequestModel(
      fName: json['f_name']?.toString(),
      lName: json['l_name']?.toString(),
      avatar: json['avatar'] != null ? File(json['avatar'] as String) : null, // Handle if API returns file path
      genderId: json['gender_id']?.toString(),
      maritalStatusId: json['marital_status_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'f_name': fName,
      'l_name': lName,
      'gender_id': genderId,
      'marital_status_id': maritalStatusId,
    };
  }

  @override
  List<Object?> get props => [fName, lName, avatar, genderId, maritalStatusId];
}