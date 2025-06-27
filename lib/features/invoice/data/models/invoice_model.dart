import 'package:equatable/equatable.dart';

import '../../../../base/data/models/code_type_model.dart';
import '../../../doctor/data/model/doctor_model.dart';

class InvoiceModel extends Equatable {
  final String? id;
  final String? cancelledReason;
  final String? totalGross;
  final String? factor;
  final String? totalNet;
  final String? paymentTerms;
  final String? note;
  final CodeModel? status;
  final DoctorModel? practitioner;

  const InvoiceModel({
    this.id,
    this.cancelledReason,
    this.totalGross,
    this.factor,
    this.totalNet,
    this.paymentTerms,
    this.note,
    this.status,
    this.practitioner,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id']?.toString(),
      cancelledReason: json['cancelled_reason'] as String?,
      totalGross: json['total_gross'] as String?,
      factor: json['factor'] as String?,
      totalNet: json['total_net'] as String?,
      paymentTerms: json['payment_terms'] as String?,
      note: json['note'] as String?,
      status: json['status'] != null ? CodeModel.fromJson(json['status'] as Map<String, dynamic>) : null,
      practitioner: json['practitioner'] != null ? DoctorModel.fromJson(json['practitioner'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (cancelledReason != null) 'cancelled_reason': cancelledReason,
      if (totalGross != null) 'total_gross': totalGross,
      if (factor != null) 'factor': factor,
      if (totalNet != null) 'total_net': totalNet,
      if (paymentTerms != null) 'payment_terms': paymentTerms,
      if (note != null) 'note': note,
      if (status != null) 'status': status!.toJson(),
      if (practitioner != null) 'practitioner': practitioner!.toJson(),
    };
  }

  InvoiceModel copyWith({
    String? id,
    String? cancelledReason,
    String? totalGross,
    String? factor,
    String? totalNet,
    String? paymentTerms,
    String? note,
    CodeModel? status,
    DoctorModel? practitioner,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      cancelledReason: cancelledReason ?? this.cancelledReason,
      totalGross: totalGross ?? this.totalGross,
      factor: factor ?? this.factor,
      totalNet: totalNet ?? this.totalNet,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      note: note ?? this.note,
      status: status ?? this.status,
      practitioner: practitioner ?? this.practitioner,
    );
  }

  @override
  List<Object?> get props => [
    id,
    cancelledReason,
    totalGross,
    factor,
    totalNet,
    paymentTerms,
    note,
    status,
    practitioner,
  ];
}