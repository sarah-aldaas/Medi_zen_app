import 'package:medizen_app/features/medical_records/observation/data/models/range_value_model.dart';

class AgeRangeModel {
  final RangeValueModel? low;
  final RangeValueModel? high;

  AgeRangeModel({required this.low, required this.high});

  factory AgeRangeModel.fromJson(Map<String, dynamic> json) {
    return AgeRangeModel(
      low: json['low'] != null ? RangeValueModel.fromJson(json['low']) : null,
      high: json['high'] != null ? RangeValueModel.fromJson(json['high']) : null,
    );
  }
}