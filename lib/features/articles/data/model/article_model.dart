import 'package:medizen_app/base/data/models/code_type_model.dart';
import 'package:medizen_app/features/doctor/data/model/doctor_model.dart';

class ArticleModel {
  final String? id;
  final String? title;
  final String? content;
  final String? source;
  final bool? isFavorite;
  final String? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final CodeModel? category;
  final DoctorModel? doctor;

  ArticleModel({this.id, this.title, this.content, this.source, this.image, this.createdAt, this.isFavorite, this.updatedAt, this.category, this.doctor});

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id']?.toString(),
      title: json['title'] as String?,
      content: json['content'] as String?,
      source: json['source'] as String?,
      image: json['image'] as String?,
      isFavorite:json['is_favorite']!=null? json['is_favorite']:false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      category: json['category'] != null ? CodeModel.fromJson(json['category'] as Map<String, dynamic>) : null,
      doctor: json['doctor'] != null ? DoctorModel.fromJson(json['doctor'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (source != null) 'source': source,
      if (image != null) 'image': image,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (category != null) 'category': category!.toJson(),
      if (doctor != null) 'doctor': doctor!.toJson(),
    };
  }

  ArticleModel copyWith({
    String? id,
    String? title,
    String? content,
    String? source,
    String? image,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    CodeModel? category,
    DoctorModel? doctor,
  }) {
    return ArticleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      source: source ?? this.source,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      doctor: doctor ?? this.doctor,
    );
  }

  @override
  String toString() {
    return 'ArticleModel(id: $id, title: $title, content: ${content?.substring(0, 20)}..., source: $source)';
  }
}
