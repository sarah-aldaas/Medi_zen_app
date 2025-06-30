import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/features/invoice/data/models/invoice_filter_model.dart';

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
    // Check if we need to show error initially
    _endDateRequiredError = _startDate != null && _endDate == null;
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate ?? DateTime.now() : _endDate ?? (_startDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // If setting start date, validate if end date is required
          _endDateRequiredError = _endDate == null;
        } else {
          _endDate = picked;
          // Clear error when end date is selected
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
      title: Text('Filter Appointments'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Start Date'),
              subtitle: Text(_startDate != null
                  ? DateFormat('yyyy-MM-dd').format(_startDate!)
                  : 'Not selected'),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, true),
            ),
            ListTile(
              title: Text('End Date'),
              subtitle: Text(_endDate != null
                  ? DateFormat('yyyy-MM-dd').format(_endDate!)
                  : 'Not selected'),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, false),
            ),
            if (_endDateRequiredError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'End date is required when start date is selected',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            if (_startDate != null || _endDate != null)
              TextButton(
                onPressed: _clearDates,
                child: Text('Clear dates'),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_startDate != null && _endDate == null) {
              setState(() => _endDateRequiredError = true);
              return;
            }

            Navigator.pop(context, InvoiceFilterModel(
              paidAppointment: widget.currentFilter.paidAppointment,
              startDate: _startDate,
              endDate: _endDate,
            ));
          },
          child: Text('Apply'),
        ),
      ],
    );
  }
}