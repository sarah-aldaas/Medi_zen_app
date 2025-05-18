import 'package:flutter/material.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';

class CancelAppointmentDialog extends StatefulWidget {
  final String appointmentId;

  const CancelAppointmentDialog({super.key, required this.appointmentId});

  @override
  State<CancelAppointmentDialog> createState() => _CancelAppointmentDialogState();
}

class _CancelAppointmentDialogState extends State<CancelAppointmentDialog> {
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
@override
  void initState() {
    _reasonController.text="Because I want choose another time.";
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: const Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "cancelAppointment.title".tr(context),
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            "cancelAppointment.message".tr(context),
            style: const TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _reasonController,
            decoration: InputDecoration(
              labelText: "Reason cancel",
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24.0),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("cancelAppointment.backButton".tr(context)),
              ),
              const SizedBox(width: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_reasonController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please enter a cancellation reason")),
                    );
                    return;
                  }
                  setState(() => _isLoading = true);
                  Navigator.of(context).pop(_reasonController.text);
                },
                child: Text("cancelAppointment.confirmButton".tr(context)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}