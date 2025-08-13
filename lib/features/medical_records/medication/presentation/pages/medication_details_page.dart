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
  final Map<String, GlobalKey> _tooltipKeys = {};

  @override
  void initState() {
    super.initState();
    _loadMedicationDetails();
  }

  void _loadMedicationDetails() {
    context.read<MedicationCubit>().getMedicationDetails(
      context: context,
      medicationId: widget.medicationId,
    );
  }

  void _showCustomTooltip(BuildContext context, String message, GlobalKey key) {
    final RenderBox renderBox =
        key.currentContext?.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;

    final overlayState = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            left: position.dx.clamp(10.0, screenSize.width - 200),
            top: position.dy + 30,
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: screenSize.width * 0.8,
                  maxHeight: 200,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    message,
                    style: TextStyle(color: AppColors.whiteColor, fontSize: 14),
                  ),
                ),
              ),
            ),
          ),
    );

    overlayState.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 4), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "medicationDetails.title".tr(context),
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadMedicationDetails();
        },
        color: Theme.of(context).primaryColor,
        child: BlocConsumer<MedicationCubit, MedicationState>(
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
              return Center(
                child: Text("medicationDetails.failedToLoad".tr(context)),
              );
            }
          },
        ),
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
          const SizedBox(height: 24),

          _buildInfoCard(
            title: "medicationDetails.dosageInfo".tr(context),
            children: [
              if (medication.dose != null && medication.doseUnit != null)
                _buildDetailRow(
                  "medicationDetails.dose".tr(context),
                  "${medication.dose} ${medication.doseUnit}",
                ),
              if (medication.maxDosePerPeriod != null)
                _buildDetailRow(
                  "medicationDetails.maxDose".tr(context),
                  "${medication.maxDosePerPeriod!.numerator.value} ${medication.maxDosePerPeriod!.numerator.unit} ${"medicationDetails.per".tr(context)} ${medication.maxDosePerPeriod!.denominator.value} ${medication.maxDosePerPeriod!.denominator.unit}",
                ),
              if (medication.dosageInstructions != null)
                _buildDetailRow(
                  "medicationDetails.instructions".tr(context),
                  medication.dosageInstructions!,
                ),
              if (medication.doseForm != null)
                _buildDetailRowWithTooltip(
                  "medicationDetails.doseForm".tr(context),
                  medication.doseForm!.display,
                  tooltip: medication.doseForm?.description,
                ),
              if (medication.route != null)
                _buildDetailRowWithTooltip(
                  "medicationDetails.route".tr(context),
                  medication.route!.display,
                  tooltip: medication.route?.description,
                ),
              if (medication.site != null)
                _buildDetailRowWithTooltip(
                  "medicationDetails.site".tr(context),
                  medication.site!.display,
                  tooltip: medication.site?.description,
                ),
            ],
          ),
          const SizedBox(height: 16),

          _buildInfoCard(
            title: "medicationDetails.patientAndAdditionalInstructions".tr(
              context,
            ),
            children: [
              if (medication.patientInstructions != null)
                _buildDetailRow(
                  "medicationDetails.patientInstructions".tr(context),
                  medication.patientInstructions!,
                ),
              if (medication.additionalInstructions != null)
                _buildDetailRow(
                  "medicationDetails.additionalInstructions".tr(context),
                  medication.additionalInstructions!,
                ),
              if (medication.asNeeded != null)
                _buildDetailRow(
                  "medicationDetails.asNeeded".tr(context),
                  medication.asNeeded!
                      ? 'medicationDetails.yes'.tr(context)
                      : 'medicationDetails.no'.tr(context),
                ),
              if (medication.when != null)
                _buildDetailRow(
                  "medicationDetails.whenToTake".tr(context),
                  medication.when!,
                ),
              if (medication.event != null)
                _buildDetailRow(
                  "medicationDetails.eventTime".tr(context),
                  medication.event!,
                ),
              if (medication.offset != null && medication.offsetUnit != null)
                _buildDetailRowWithTooltip(
                  "medicationDetails.offset".tr(context),
                  "${medication.offset} ${medication.offsetUnit!.length}",
                ),
            ],
          ),
          const SizedBox(height: 16),

          _buildInfoCard(
            title: "medicationDetails.statusAndDates".tr(context),
            children: [
              if (medication.status != null)
                _buildDetailRowWithTooltip(
                  "medicationDetails.status".tr(context),
                  medication.status!.display,
                  tooltip: medication.status?.description,
                ),
              if (medication.effectiveMedicationStartDate != null)
                _buildDetailRow(
                  "medicationDetails.startDate".tr(context),
                  DateFormat(
                    'MMM d, y',
                  ).format(medication.effectiveMedicationStartDate!),
                ),
              if (medication.effectiveMedicationEndDate != null)
                _buildDetailRow(
                  "medicationDetails.endDate".tr(context),
                  DateFormat(
                    'MMM d, y',
                  ).format(medication.effectiveMedicationEndDate!),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(MedicationModel medication) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.medication, color: AppColors.primaryColor, size: 60),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                medication.name ??
                    'medicationDetails.unknownMedication'.tr(context),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                medication.definition ??
                    'medicationDetails.noDescriptionAvailable'.tr(context),
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.green,
              ),
            ),
            const Divider(height: 16, thickness: 1),
            ...children
                .map(
                  (widget) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: widget,
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            "$label:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.cyan1,
            ),
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 15))),
      ],
    );
  }

  Widget _buildDetailRowWithTooltip(
    String label,
    String value, {
    String? tooltip,
  }) {
    final key = ValueKey(label);
    _tooltipKeys[label] = _tooltipKeys[label] ?? GlobalKey();

    Widget valueWidget = Text(value, style: const TextStyle(fontSize: 15));

    if (tooltip != null && tooltip.isNotEmpty) {
      valueWidget = GestureDetector(
        onTap: () => _showCustomTooltip(context, tooltip, _tooltipKeys[label]!),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            key: _tooltipKeys[label],
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: valueWidget,
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            "$label:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.cyan1,
            ),
          ),
        ),
        Expanded(child: valueWidget),
      ],
    );
  }
}
