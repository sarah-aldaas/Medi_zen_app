import '../../../../base/data/models/code_type_model.dart';
import '../../../../base/data/models/meta_model.dart';

class TelecomModel {
  final String? id;
  final String? value;
  final String? rank;
  final String? startDate;
  final String? endDate;
  final String? typeId;
  final String? useId;

  final CodeModel? type;
  final CodeModel? use;

  TelecomModel({
    required this.id,
    required this.value,
    required this.rank,
    this.startDate,
    this.endDate,
    required this.type,
    required this.use,

    required this.typeId,
    required this.useId,
  });

  factory TelecomModel.fromJson(Map<String, dynamic> json) {
    return TelecomModel(
      id: json['id']!=null?json['id'].toString():null,
      value:json['value']!=null? json['value'].toString():null,
      rank: json['rank']!=null? json['rank'].toString():null,
      startDate:json['start_date']!=null?  json['start_date']?.toString():null,
      endDate:json['end_date']!=null? json['end_date']?.toString():null,
      type: json['type']!=null?CodeModel.fromJson(json['type'] as Map<String, dynamic>):null,
      use: json['use']!=null?CodeModel.fromJson(json['use'] as Map<String, dynamic>):null,
      typeId: json['type']['id']!=null?json['type']["id"].toString():null,
      useId: json['use']['id']!=null?json['use']["id"].toString():null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'value': value.toString(),
      'rank': rank.toString(),
      'start_date': DateTime.now().toString(),

      'type': type!.toJson(),
      'use': use!.toJson(),
      'use_id':useId.toString(),
      'type_id':typeId.toString()
    };
  }
}
class TelecomsDataModel {
  final List<TelecomModel> data;
  final MetaModel? meta;
  final LinksModel? links;

  TelecomsDataModel({
    required this.data,
    required this.meta,
    required this.links,
  });

  factory TelecomsDataModel.fromJson(Map<String, dynamic> json) {
    return TelecomsDataModel(
      data:json.containsKey('telecoms')? (json['telecoms']['data'] as List<dynamic>?)
          ?.map((item) => TelecomModel.fromJson(item as Map<String, dynamic>))
          .toList() ??
          []:[],
      meta:json['meta'] != null? MetaModel.fromJson(json['meta'] as Map<String, dynamic>):null,
      links:json['links'] != null? LinksModel.fromJson(json['links'] as Map<String, dynamic>):null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
      'meta': meta!.toJson(),
      'links': links!.toJson(),
    };
  }
}