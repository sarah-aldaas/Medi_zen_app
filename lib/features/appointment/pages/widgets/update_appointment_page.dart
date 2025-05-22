import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/appointment/data/models/appointment_update_model.dart';

import '../../../../base/theme/app_color.dart';
import '../cubit/appointment_cubit/appointment_cubit.dart';

class UpdateAppointmentPage extends StatefulWidget {
  final String appointmentId;
  final String initialReason;
  final String initialDescription;
  final String? initialNote;

  const UpdateAppointmentPage({
    super.key,
    required this.appointmentId,
    required this.initialReason,
    required this.initialDescription,
    this.initialNote,
  });

  @override
  State<UpdateAppointmentPage> createState() => _UpdateAppointmentPageState();
}

class _UpdateAppointmentPageState extends State<UpdateAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _reasonController;
  late TextEditingController _descriptionController;
  late TextEditingController _noteController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController(text: widget.initialReason);
    _descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
    _noteController = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final updateModel = AppointmentUpdateModel(
        reason: _reasonController.text,
        description: _descriptionController.text,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
      );

      await context.read<AppointmentCubit>().updateAppointment(
        id: widget.appointmentId,
        appointmentModel: updateModel,
      );

      if (mounted) {
        Navigator.of(context).pop(true); // Return success
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "Update appointment",
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              spacing: 5,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Gap(40),
                TextFormField(
                  controller: _reasonController,
                  decoration: InputDecoration(
                    labelText: "Reason",
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Reason is required";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "description is required";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: "Note",
                    border: const OutlineInputBorder(),
                    hintText: "Note optional",
                  ),
                ),
                const SizedBox(height: 35),
                if (_isLoading)
                  Center(child: LoadingButton())
                else
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text("Save"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
