import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/theme/app_color.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';

import '../../data/models/medication_model.dart';
import '../cubit/medication_cubit/medication_cubit.dart';

class MedicationDetailsPage extends StatefulWidget {
  final String medicationId;

  const MedicationDetailsPage({super.key, required this.medicationId});

  @override
  _MedicationDetailsPageState createState() => _MedicationDetailsPageState();
}

class _MedicationDetailsPageState extends State<MedicationDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<MedicationCubit>().getMedicationDetails(context: context, medicationId: widget.medicationId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "medicationDetails.title".tr(context),
          style: TextStyle(color: AppColors.primaryColor, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<MedicationCubit, MedicationState>(
        listener: (context, state) {
          if (state is MedicationError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is MedicationDetailsSuccess) {
            return _buildMedicationDetails(state.medication);
          } else if (state is MedicationLoading) {
            return const Center(child: LoadingPage());
          } else {
            return Center(child: Text("medicationDetails.failedToLoad".tr(context)));
          }
        },
      ),
    );
  }

  Widget _buildMedicationDetails(MedicationModel medication) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(medication),
          const SizedBox(height: 20),
          _buildDosageInfo(medication),
          const SizedBox(height: 20),
          _buildInstructions(medication),
          const SizedBox(height: 20),
          _buildStatusAndDates(medication),
        ],
      ),
    );
  }

  Widget _buildHeader(MedicationModel medication) {
    return Row(
      children: [
        Icon(Icons.medication, color: AppColors.primaryColor, size: 50),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                medication.name ?? 'Unknown Medication',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                medication.definition ?? 'No description available',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDosageInfo(MedicationModel medication) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "medicationDetails.dosageInfo".tr(context),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.cyan),
        ),
        const SizedBox(height: 8),
        if (medication.dose != null && medication.doseUnit != null)
          Text("Dose: ${medication.dose} ${medication.doseUnit}"),
        if (medication.maxDosePerPeriod != null)
          Text("Max Dose: ${medication.maxDosePerPeriod!.numerator.value} ${medication.maxDosePerPeriod!.numerator.unit} per ${medication.maxDosePerPeriod!.denominator.value} ${medication.maxDosePerPeriod!.denominator.unit}"),
        if (medication.dosageInstructions != null)
          Text("Instructions: ${medication.dosageInstructions}"),
      ],
    );
  }

  Widget _buildInstructions(MedicationModel medication) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "medicationDetails.instructions".tr(context),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.cyan),
        ),
        const SizedBox(height: 8),
        if (medication.patientInstructions != null)
          Text("Patient Instructions: ${medication.patientInstructions}"),
        if (medication.additionalInstructions != null)
          Text("Additional Instructions: ${medication.additionalInstructions}"),
        if (medication.asNeeded != null)
          Text("As Needed: ${medication.asNeeded! ? 'Yes' : 'No'}"),
      ],
    );
  }

  Widget _buildStatusAndDates(MedicationModel medication) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "medicationDetails.statusAndDates".tr(context),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.cyan),
        ),
        const SizedBox(height: 8),
        if (medication.status != null)
          Text("Status: ${medication.status!.display}"),
        if (medication.effectiveMedicationStartDate != null)
          Text("Start Date: ${DateFormat('MMM d, y').format(medication.effectiveMedicationStartDate!)}"),
        if (medication.effectiveMedicationEndDate != null)
          Text("End Date: ${DateFormat('MMM d, y').format(medication.effectiveMedicationEndDate!)}"),
      ],
    );
  }
}