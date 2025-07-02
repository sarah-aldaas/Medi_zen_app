import 'package:intl/intl.dart';

class InvoiceFilterModel {
  final bool paidAppointment;
  final DateTime? startDate;
  final DateTime? endDate;

  InvoiceFilterModel({required this.paidAppointment, this.startDate, this.endDate});

  Map<String, dynamic> toJson() {
    return {
      'paid_appointment': paidAppointment?1:0,
      if (startDate != null) 'start_date_created_at': DateFormat('yyyy-MM-dd').format(startDate!),
      if (endDate != null) 'end_date_created_at': DateFormat('yyyy-MM-dd').format(endDate!),
    };
  }

  InvoiceFilterModel copyWith({required bool paidAppointment, DateTime? startDate, DateTime? endDate}) {
    return InvoiceFilterModel(paidAppointment: paidAppointment, startDate: startDate ?? this.startDate, endDate: endDate ?? this.endDate);
  }
}
