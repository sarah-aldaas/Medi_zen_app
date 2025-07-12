import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/theme/app_color.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/base/widgets/not_found_data_page.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import 'package:medizen_app/features/medical_records/medication_request/presentation/pages/medication_request_details_page.dart';
import '../../data/models/medication_request_filter.dart';
import '../../data/models/medication_request_model.dart';
import '../cubit/medication_request_cubit/medication_request_cubit.dart';

class MyMedicationRequestsOfAppointmentPage extends StatefulWidget {
  final String appointmentId;
  final MedicationRequestFilterModel filter;

  const MyMedicationRequestsOfAppointmentPage({super.key, required this.filter, required this.appointmentId});

  @override
  _MyMedicationRequestsOfAppointmentPageState createState() => _MyMedicationRequestsOfAppointmentPageState();
}

class _MyMedicationRequestsOfAppointmentPageState extends State<MyMedicationRequestsOfAppointmentPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialMedicationRequests();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialMedicationRequests() {
    _isLoadingMore = false;
    context.read<MedicationRequestCubit>().getMedicationRequestsForAppointment(context: context, filters: widget.filter.toJson(),appointmentId: widget.appointmentId);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context
          .read<MedicationRequestCubit>()
          .getMedicationRequestsForAppointment(filters: widget.filter.toJson(), loadMore: true, context: context,appointmentId: widget.appointmentId)
          .then((_) => setState(() => _isLoadingMore = false));
    }
  }

  @override
  void didUpdateWidget(MyMedicationRequestsOfAppointmentPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.filter != oldWidget.filter) {
      _loadInitialMedicationRequests();
      // _scrollController.jumpTo(0.0);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<MedicationRequestCubit, MedicationRequestState>(
        listener: (context, state) {
          // if (state is MedicationRequestError) {
          //   ShowToast.showToastError(message: state.error);
          // }
        },
        builder: (context, state) {
          if (state is MedicationRequestLoading && !state.isLoadMore) {
            return const Center(child: LoadingPage());
          }

          final medicationRequests = state is MedicationRequestSuccess ? state.paginatedResponse.paginatedData!.items : [];
          final hasMore = state is MedicationRequestSuccess ? state.hasMore : false;

          if (medicationRequests.isEmpty) {
            return NotFoundDataPage();
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadInitialMedicationRequests();
            },
            color: Theme.of(context).primaryColor,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: medicationRequests.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < medicationRequests.length) {
                  return _buildMedicationRequestCard(medicationRequests[index]);
                } else if (hasMore && state is! MedicationRequestError) {
                  return Center(child: LoadingButton());
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMedicationRequestCard(MedicationRequestModel request) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MedicationRequestDetailsPage(medicationRequestId: request.id.toString())),
          ).then((_) => _loadInitialMedicationRequests()),
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
                  Icon(Icons.receipt_long, color: AppColors.primaryColor, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(request.reason ?? 'Medication Request', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(request.note ?? 'No additional notes', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (request.status != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                      child: Text(request.status!.display, style: TextStyle(color: AppColors.primaryColor)),
                    ),
                  const Spacer(),
                  if (request.statusChanged != null) Text(request.statusChanged!, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
