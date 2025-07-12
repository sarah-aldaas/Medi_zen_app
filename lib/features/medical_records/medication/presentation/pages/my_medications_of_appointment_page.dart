import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/theme/app_color.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/base/widgets/not_found_data_page.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import 'package:medizen_app/features/medical_records/medication/presentation/pages/medication_details_page.dart';
import '../../data/models/medication_filter_model.dart';
import '../../data/models/medication_model.dart';
import '../cubit/medication_cubit/medication_cubit.dart';

class MyMedicationsOfAppointmentPage extends StatefulWidget {
  final String appointmentId;
  final MedicationFilterModel filter;

  const MyMedicationsOfAppointmentPage({super.key, required this.filter, required this.appointmentId});

  @override
  _MyMedicationsOfAppointmentPageState createState() => _MyMedicationsOfAppointmentPageState();
}

class _MyMedicationsOfAppointmentPageState extends State<MyMedicationsOfAppointmentPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialMedications();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialMedications() {
    _isLoadingMore = false;
    context.read<MedicationCubit>().getMedicationsForAppointment(context: context, filters: widget.filter.toJson(), appointmentId: widget.appointmentId);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context
          .read<MedicationCubit>()
          .getMedicationsForAppointment(filters: widget.filter.toJson(), loadMore: true, context: context,appointmentId: widget.appointmentId)
          .then((_) => setState(() => _isLoadingMore = false));
    }
  }
  @override
  void didUpdateWidget(MyMedicationsOfAppointmentPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.filter != oldWidget.filter) {
      _loadInitialMedications();
      // _scrollController.jumpTo(0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<MedicationCubit, MedicationState>(
        listener: (context, state) {
          // if (state is MedicationError) {
          //   ShowToast.showToastError(message: state.error);
          // }
        },
        builder: (context, state) {
          if (state is MedicationLoading && !state.isLoadMore) {
            return const Center(child: LoadingPage());
          }

          final medications = state is MedicationSuccess ? state.paginatedResponse.paginatedData!.items : [];
          final hasMore = state is MedicationSuccess ? state.hasMore : false;

          if (medications.isEmpty) {
            return NotFoundDataPage();
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadInitialMedications();
            },
            color: Theme.of(context).primaryColor,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: medications.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < medications.length) {
                  return _buildMedicationCard(medications[index]);
                } else if (hasMore && state is! MedicationError) {
                  return  Center(child: LoadingButton());
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMedicationCard(MedicationModel medication) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MedicationDetailsPage(medicationId: medication.id.toString())),
          ).then((_) => _loadInitialMedications()),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.medication, color: AppColors.primaryColor, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(medication.name ?? 'Unknown Medication', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(medication.dosageInstructions ?? 'No instructions', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (medication.status != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                      child: Text(medication.status!.display, style: TextStyle(color: AppColors.primaryColor)),
                    ),
                  const Spacer(),
                  if (medication.effectiveMedicationStartDate != null)
                    Text(DateFormat('MMM d, y').format(medication.effectiveMedicationStartDate!), style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
