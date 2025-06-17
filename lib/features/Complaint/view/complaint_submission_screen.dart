import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/theme/app_color.dart';
import 'package:medizen_app/features/Complaint/view/widget/complaint_dropdown.dart';
import 'package:medizen_app/features/Complaint/view/widget/complaint_submit_button.dart';
import 'package:medizen_app/features/Complaint/view/widget/complaint_text_field.dart';

import '../cubit/complaint_cubit.dart';

class ComplaintSubmissionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ComplaintCubit(),
      child: ComplaintSubmissionView(),
    );
  }
}

class ComplaintSubmissionView extends StatelessWidget {
  final List<String> clinics = ['clinic 1', 'clinic 2', 'clinic 3'];
  final List<String> doctors = ['doctor 1', 'doctor 2', 'doctor 3'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: AppColors.primaryColor),
        ),
        title: Text(
          'Complaint.title'.tr(context),
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ComplaintDropdown(
              items: clinics,
              hintText: 'Complaint.Clinic'.tr(context),
              onChanged:
                  (value) => context.read<ComplaintCubit>().selectClinic(value),
            ),
            SizedBox(height: 40),
            ComplaintDropdown(
              items: doctors,
              hintText: 'Complaint.Doctor'.tr(context),
              onChanged:
                  (value) => context.read<ComplaintCubit>().selectDoctor(value),
            ),
            SizedBox(height: 40),
            ComplaintTextField(
              hintText: 'Complaint.ComplaintContent'.tr(context),
              onChanged:
                  (value) => context
                      .read<ComplaintCubit>()
                      .updateComplaintContent(value),
            ),
            SizedBox(height: 40),
            ComplaintSubmitButton(
              onPressed: () => context.read<ComplaintCubit>().submitComplaint(),
            ),
          ],
        ),
      ),
    );
  }
}
