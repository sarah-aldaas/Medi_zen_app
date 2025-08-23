import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/features/invoice/data/models/invoice_filter_model.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';

import '../../../../base/theme/app_color.dart';

class InvoiceFilterDialog extends StatefulWidget {
  final InvoiceFilterModel currentFilter;

  const InvoiceFilterDialog({super.key, required this.currentFilter});

  @override
  _InvoiceFilterDialogState createState() => _InvoiceFilterDialogState();
}

class _InvoiceFilterDialogState extends State<InvoiceFilterDialog> {
  late DateTime? _startDate;
  late DateTime? _endDate;
  bool _endDateRequiredError = false;

  @override
  void initState() {
    super.initState();
    _startDate = widget.currentFilter.startDate;
    _endDate = widget.currentFilter.endDate;
    _endDateRequiredError = _startDate != null && _endDate == null;
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
      isStartDate
          ? _startDate ?? DateTime.now()
          : _endDate ?? (_startDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          _endDateRequiredError = _endDate == null;
        } else {
          _endDate = picked;
          _endDateRequiredError = false;
        }
      });
    }
  }

  void _clearDates() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _endDateRequiredError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Text(
        'invoiceFilterDialog.title'.tr(context),
        style: TextStyle(
          fontSize: 20,
          color: AppColors.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                'invoiceFilterDialog.startDate'.tr(context),
                style: TextStyle(color: AppColors.green),
              ),
              subtitle: Text(
                _startDate != null
                    ? DateFormat('yyyy-MM-dd').format(_startDate!)
                    : 'invoiceFilterDialog.notSelected'.tr(context),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, true),
            ),
            ListTile(
              title: Text(
                'invoiceFilterDialog.endDate'.tr(context),
                style: TextStyle(color: AppColors.green),
              ),
              subtitle: Text(
                _endDate != null
                    ? DateFormat('yyyy-MM-dd').format(_endDate!)
                    : 'invoiceFilterDialog.notSelected'.tr(context),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, false),
            ),
            if (_endDateRequiredError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'invoiceFilterDialog.endDateRequiredError'.tr(context),
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            if (_startDate != null || _endDate != null)
              TextButton(
                onPressed: _clearDates,
                child: Text('invoiceFilterDialog.clearDates'.tr(context)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'invoiceFilterDialog.cancelButton'.tr(context),
            style: TextStyle(color: AppColors.primaryColor),
          ),
        ),
        TextButton(
          onPressed: () {
            if (_startDate != null && _endDate == null) {
              setState(() => _endDateRequiredError = true);
              return;
            }

            Navigator.pop(
              context,
              InvoiceFilterModel(
                paidAppointment: widget.currentFilter.paidAppointment,
                startDate: _startDate,
                endDate: _endDate,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text('invoiceFilterDialog.applyButton'.tr(context)),
        ),
      ],
    );
  }
}