import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/theme/app_color.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';

import '../../data/models/medication_request_model.dart';
import '../cubit/medication_request_cubit/medication_request_cubit.dart';

class MedicationRequestDetailsPage extends StatefulWidget {
  final String medicationRequestId;

  const MedicationRequestDetailsPage({super.key, required this.medicationRequestId});

  @override
  _MedicationRequestDetailsPageState createState() => _MedicationRequestDetailsPageState();
}

class _MedicationRequestDetailsPageState extends State<MedicationRequestDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<MedicationRequestCubit>().getMedicationRequestDetails(
      context: context,
      medicationRequestId: widget.medicationRequestId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "medicationRequestDetails.title".tr(context),
          style: TextStyle(color: AppColors.primaryColor, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<MedicationRequestCubit, MedicationRequestState>(
        listener: (context, state) {
          if (state is MedicationRequestError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is MedicationRequestDetailsSuccess) {
            return _buildMedicationRequestDetails(state.medicationRequest);
          } else if (state is MedicationRequestLoading) {
            return const Center(child: LoadingPage());
          } else {
            return Center(child: Text("medicationRequestDetails.failedToLoad".tr(context)));
          }
        },
      ),
    );
  }

  Widget _buildMedicationRequestDetails(MedicationRequestModel request) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(request),
          const SizedBox(height: 20),
          _buildRequestInfo(request),
          const SizedBox(height: 20),
          _buildConditionInfo(request),
          const SizedBox(height: 20),
          _buildAdditionalInfo(request),
        ],
      ),
    );
  }

  Widget _buildHeader(MedicationRequestModel request) {
    return Row(
      children: [
        Icon(Icons.receipt_long, color: AppColors.primaryColor, size: 50),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                request.reason ?? 'Medication Request',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                request.status?.display ?? 'No status',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequestInfo(MedicationRequestModel request) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "medicationRequestDetails.requestInfo".tr(context),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.cyan),
        ),
        const SizedBox(height: 8),
        if (request.status != null)
          Text("Status: ${request.status!.display}"),
        if (request.statusReason != null)
          Text("Status Reason: ${request.statusReason}"),
        if (request.statusChanged != null)
          Text("Status Changed: ${request.statusChanged}"),
        if (request.intent != null)
          Text("Intent: ${request.intent!.display}"),
        if (request.priority != null)
          Text("Priority: ${request.priority!.display}"),
      ],
    );
  }

  Widget _buildConditionInfo(MedicationRequestModel request) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "medicationRequestDetails.conditionInfo".tr(context),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.cyan),
        ),
        const SizedBox(height: 8),
        if (request.condition != null)
          Text("Condition: ${request.condition!.healthIssue ?? 'No condition'}"),
        if (request.condition?.clinicalStatus != null)
          Text("Clinical Status: ${request.condition!.clinicalStatus!.display}"),
      ],
    );
  }

  Widget _buildAdditionalInfo(MedicationRequestModel request) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "medicationRequestDetails.additionalInfo".tr(context),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.cyan),
        ),
        const SizedBox(height: 8),
        if (request.courseOfTherapyType != null)
          Text("Course of Therapy: ${request.courseOfTherapyType!.display}"),
        if (request.numberOfRepeatsAllowed != null)
          Text("Repeats Allowed: ${request.numberOfRepeatsAllowed}"),
        if (request.note != null)
          Text("Note: ${request.note}"),
        if (request.doNotPerform != null)
          Text("Do Not Perform: ${request.doNotPerform! ? 'Yes' : 'No'}"),
      ],
    );
  }
}