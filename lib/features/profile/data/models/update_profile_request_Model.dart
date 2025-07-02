import 'dart:io';

import 'package:equatable/equatable.dart';

class UpdateProfileRequestModel extends Equatable {
  final String? fName;
  final String? lName;
  final File? avatar;
  final String? genderId;
  final String? maritalStatusId;
  final String? image;

  const UpdateProfileRequestModel({
    this.fName,
    this.lName,
    this.avatar,
    this.genderId,
    this.maritalStatusId,
    this.image,
  });

  factory UpdateProfileRequestModel.fromJson(Map<String, dynamic> json) {
    return UpdateProfileRequestModel(
      fName: json['f_name']?.toString(),
      lName: json['l_name']?.toString(),
      avatar: json['avatar'] != null ? File(json['avatar'] as String) : null,
      genderId: json['gender_id']?.toString(),
      maritalStatusId: json['marital_status_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'f_name': fName,
      'l_name': lName,
      'gender_id': genderId,
      'marital_status_id': maritalStatusId,
    };
    if (image == null) {
      if (avatar != null) {
        data['avatar'] = avatar!.path;
      } else {
        data['avatar'] = null;
      }
    }
    return data;
  }

  @override
  List<Object?> get props => [fName, lName, avatar, genderId, maritalStatusId];
}
