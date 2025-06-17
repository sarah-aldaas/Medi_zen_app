import 'package:flutter/material.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';

import '../../../../base/theme/app_color.dart';
import '../../../../base/widgets/show_toast.dart';

class CancelAppointmentDialog extends StatefulWidget {
  final String appointmentId;

  const CancelAppointmentDialog({super.key, required this.appointmentId});

  @override
  State<CancelAppointmentDialog> createState() =>
      _CancelAppointmentDialogState();
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
    _reasonController.text = "Because I want choose another time.";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 20.0),
          Text(
            "cancelAppointment.message".tr(context),
            style: const TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 35.0),
          TextField(
            controller: _reasonController,
            decoration: InputDecoration(
              labelText: "Reason cancel",
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 45.0),
          _isLoading
              ?  Center(child: LoadingButton())
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
                        ShowToast.showToastError(message: "Please enter a cancellation reason");
                        return;
                      }
                      setState(() => _isLoading = true);
                      Navigator.of(context).pop(_reasonController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor.withOpacity(0.7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      elevation: 3,
                    ),
                    child: Text("cancelAppointment.confirmButton".tr(context)),
                  ),
                ],
              ),
        ],
      ),
    );
  }
}
