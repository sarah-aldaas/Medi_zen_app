import 'dart:io';

import 'package:intl/intl.dart';

import '../../../../base/data/models/code_type_model.dart';
import '../../../appointment/data/models/appointment_model.dart';

class ComplainModel {
  final String? id;
  final String? title;
  final String? description;
  final bool? assignedToAdmin;
  final DateTime? statusChangedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final CodeModel? status;
  final CodeModel? type;
  final AppointmentModel? appointment;
  final List<File>? attachmentsFiles;
  final List<ComplaintResponseAttachment>? attachmentsUrl;
  final List<ComplainResponseModel>? responses;

  ComplainModel({
    this.id,
    this.title,
    this.description,
    this.assignedToAdmin,
    this.statusChangedAt,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.type,
    this.appointment,
    this.attachmentsFiles,
    this.attachmentsUrl,
    this.responses,
  });

  ComplainModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? assignedToAdmin,
    DateTime? statusChangedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    CodeModel? status,
    CodeModel? type,
    AppointmentModel? appointment,
    List<File>? attachmentsFiles,
    final List<ComplaintResponseAttachment>? attachmentsUrl,
    List<ComplainResponseModel>? responses,
  }) {
    return ComplainModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedToAdmin: assignedToAdmin ?? this.assignedToAdmin,
      statusChangedAt: statusChangedAt ?? this.statusChangedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      type: type ?? this.type,
      appointment: appointment ?? this.appointment,
      attachmentsFiles: attachmentsFiles ?? this.attachmentsFiles,
      attachmentsUrl: attachmentsUrl ?? this.attachmentsUrl,
      responses: responses ?? this.responses,
    );
  }

  factory ComplainModel.fromJson(Map<String, dynamic> json) {
    return ComplainModel(
      id: json['id']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      assignedToAdmin: json['assigned_to_admin'] ?? false,
      statusChangedAt:
          json['status_changed_at'] != null
              ? DateTime.tryParse(json['status_changed_at'])
              : null,
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'])
              : null,
      status:
          json['status'] != null ? CodeModel.fromJson(json['status']) : null,
      type: json['type'] != null ? CodeModel.fromJson(json['type']) : null,
      appointment:
          json['appointment'] != null
              ? AppointmentModel.fromJson(json['appointment'])
              : null,

      attachmentsUrl:
      json['attachments'] != null
          ? List<ComplaintResponseAttachment>.from(
        (json['attachments'] as List).map(
              (x) => ComplaintResponseAttachment.fromJson(
            x as Map<String, dynamic>,
          ),
        ),
      )
          : [],
      responses:
          json['responses'] is List
              ? List<ComplainResponseModel>.from(
                json['responses'].map((x) => ComplainResponseModel.fromJson(x)),
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    final dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    return {
      'id': id,
      'title': title,
      'description': description,
      'assigned_to_admin': assignedToAdmin,
      'status_changed_at':
          statusChangedAt != null ? dateFormat.format(statusChangedAt!) : null,
      'created_at': createdAt != null ? dateFormat.format(createdAt!) : null,
      'updated_at': updatedAt != null ? dateFormat.format(updatedAt!) : null,
      'status': status?.toJson(),
      'type': type?.toJson(),
      'appointment': appointment?.toJson(),
      'attachments_url': attachmentsUrl,
      'responses': responses?.map((x) => x.toJson()).toList(),
    };
  }

  Map<String, dynamic> createJson() {
    return {'title': title, 'description': description, 'type_id': type!.id};
  }
}

class ComplaintResponseAttachment {
  final int id;
  final String fileUrl;

  ComplaintResponseAttachment({required this.id, required this.fileUrl});

  factory ComplaintResponseAttachment.fromJson(Map<String, dynamic> json) {
    return ComplaintResponseAttachment(
      id: json['id'] as int,
      fileUrl: json['file_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'file_url': fileUrl};
  }
}

class ComplainResponseModel {
  final String? id;
  final String? response;
  final String? senderId;
  final String? senderType;
  final SenderModel? sender;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<File>? attachmentsFile;
  final List<ComplaintResponseAttachment>? attachmentsUrl;

  ComplainResponseModel({
    this.id,
    this.response,
    this.senderId,
    this.senderType,
    this.sender,
    this.createdAt,
    this.updatedAt,
    this.attachmentsFile,
    this.attachmentsUrl,
  });

  factory ComplainResponseModel.fromJson(Map<String, dynamic> json) {
    return ComplainResponseModel(
      id: json['id']?.toString(),
      response: json['response']?.toString(),
      senderId: json['sender_id']?.toString(),
      senderType: json['sender_type']?.toString(),
      sender:
          json['sender'] != null ? SenderModel.fromJson(json['sender']) : null,
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'])
              : null,
      attachmentsUrl:
          json['attachments'] != null
              ? List<ComplaintResponseAttachment>.from(
                (json['attachments'] as List).map(
                  (x) => ComplaintResponseAttachment.fromJson(
                    x as Map<String, dynamic>,
                  ),
                ),
              )
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    final dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    return {
      'id': id,
      'response': response,
      'sender_id': senderId,
      'sender_type': senderType,
      'sender': sender?.toJson(),
      'created_at': createdAt != null ? dateFormat.format(createdAt!) : null,
      'updated_at': updatedAt != null ? dateFormat.format(updatedAt!) : null,
    };
  }
}

class SenderModel {
  final String? id;
  final String? fName;
  final String? lName;
  final String? text;
  final String? family;
  final String? given;
  final String? prefix;
  final String? suffix;
  final String? avatar;
  final String? address;
  final String? dateOfBirth;
  final String? deceasedDate;
  final String? email;
  final String? emailVerifiedAt;
  final bool? active;
  final int? height;
  final int? weight;
  final bool? smoker;
  final bool? alcoholDrinker;

  SenderModel({
    this.id,
    this.fName,
    this.lName,
    this.text,
    this.family,
    this.given,
    this.prefix,
    this.suffix,
    this.avatar,
    this.address,
    this.dateOfBirth,
    this.deceasedDate,
    this.email,
    this.emailVerifiedAt,
    this.active,
    this.height,
    this.weight,
    this.smoker,
    this.alcoholDrinker,
  });

  factory SenderModel.fromJson(Map<String, dynamic> json) {
    return SenderModel(
      id: json['id']?.toString(),
      fName: json['f_name']?.toString(),
      lName: json['l_name']?.toString(),
      text: json['text']?.toString(),
      family: json['family']?.toString(),
      given: json['given']?.toString(),
      prefix: json['prefix']?.toString(),
      suffix: json['suffix']?.toString(),
      avatar: json['avatar']?.toString(),
      address: json['address']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      deceasedDate: json['deceased_date']?.toString(),
      email: json['email']?.toString(),
      emailVerifiedAt: json['email_verified_at']?.toString(),
      active: json['active'] == 1,
      height: json['height'] is int ? json['height'] : null,
      weight: json['weight'] is int ? json['weight'] : null,
      smoker: json['smoker'] == 1,
      alcoholDrinker: json['alcohol_drinker'] == 1,
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
      'active': active != null ? (active! ? 1 : 0) : null,
      'height': height,
      'weight': weight,
      'smoker': smoker != null ? (smoker! ? 1 : 0) : null,
      'alcohol_drinker':
          alcoholDrinker != null ? (alcoholDrinker! ? 1 : 0) : null,
    };
  }
}
