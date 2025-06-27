import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/go_router/go_router.dart';
import 'package:medizen_app/base/theme/app_color.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';

import '../../data/models/medication_request_filter.dart';
import '../../data/models/medication_request_model.dart';
import '../cubit/medication_request_cubit/medication_request_cubit.dart';
import '../widgets/medication_request_filter_dialog.dart';

class MyMedicationRequestsPage extends StatefulWidget {
  const MyMedicationRequestsPage({super.key});

  @override
  _MyMedicationRequestsPageState createState() => _MyMedicationRequestsPageState();
}

class _MyMedicationRequestsPageState extends State<MyMedicationRequestsPage> {
  final ScrollController _scrollController = ScrollController();
  MedicationRequestFilterModel _filter = MedicationRequestFilterModel();
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
    context.read<MedicationRequestCubit>().getAllMedicationRequests(
      context: context,
      filters: _filter.toJson(),
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context
          .read<MedicationRequestCubit>()
          .getAllMedicationRequests(
        filters: _filter.toJson(),
        loadMore: true,
        context: context,
      )
          .then((_) => setState(() => _isLoadingMore = false));
    }
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<MedicationRequestFilterModel>(
      context: context,
      builder: (context) => MedicationRequestFilterDialog(currentFilter: _filter),
    );

    if (result != null) {
      setState(() => _filter = result);
      _loadInitialMedicationRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pushReplacementNamed(AppRouter.homePage.name),
          icon: Icon(Icons.arrow_back, color: AppColors.primaryColor),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "myMedicationRequests.title".tr(context),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: AppColors.primaryColor),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: BlocConsumer<MedicationRequestCubit, MedicationRequestState>(
        listener: (context, state) {
          if (state is MedicationRequestError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is MedicationRequestLoading && !state.isLoadMore) {
            return const Center(child: LoadingPage());
          }

          final medicationRequests = state is MedicationRequestSuccess ? state.paginatedResponse.paginatedData!.items : [];
          final hasMore = state is MedicationRequestSuccess ? state.hasMore : false;

          if (medicationRequests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medical_services, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    "myMedicationRequests.noRequests".tr(context),
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            itemCount: medicationRequests.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < medicationRequests.length) {
                return _buildMedicationRequestCard(medicationRequests[index]);
              } else if (hasMore && state is! MedicationRequestError) {
                return const Center(child: CircularProgressIndicator());
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Widget _buildMedicationRequestCard(MedicationRequestModel request) {
    return GestureDetector(
      onTap: () => context.pushNamed(
        AppRouter.medicationRequestDetails.name,
        extra: {"id": request.id.toString()},
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
                        Text(
                          request.reason ?? 'Medication Request',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request.note ?? 'No additional notes',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
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
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        request.status!.display,
                        style: TextStyle(color: AppColors.primaryColor),
                      ),
                    ),
                  const Spacer(),
                  if (request.statusChanged != null)
                    Text(
                      request.statusChanged!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}