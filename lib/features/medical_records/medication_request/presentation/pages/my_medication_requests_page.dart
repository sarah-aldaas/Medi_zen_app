import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/theme/app_color.dart';
import 'package:medizen_app/base/widgets/not_found_data_page.dart';
import 'package:medizen_app/features/medical_records/medication_request/presentation/pages/medication_request_details_page.dart';

import '../../../../../base/widgets/loading_page.dart';
import '../../data/models/medication_request_model.dart';
import '../cubit/medication_request_cubit/medication_request_cubit.dart';

class MyMedicationRequestsPage extends StatefulWidget {
  // final MedicationRequestFilterModel filter;
  final String conditionId;
  const MyMedicationRequestsPage({super.key,required this.conditionId});

  @override
  _MyMedicationRequestsPageState createState() =>
      _MyMedicationRequestsPageState();
}

class _MyMedicationRequestsPageState extends State<MyMedicationRequestsPage> {
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
    context.read<MedicationRequestCubit>().getMedicationRequestForCondition(
      conditionId:widget.conditionId ,
      context: context,
      // filters: widget.filter.toJson(),
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context
          .read<MedicationRequestCubit>()
          .getMedicationRequestForCondition(
        conditionId:widget.conditionId,
            // filters: widget.filter.toJson(),
            loadMore: true,
            context: context,
          )
          .then((_) => setState(() => _isLoadingMore = false));
    }
  }

  // @override
  // void didUpdateWidget(MyMedicationRequestsPage oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //
  //   if (widget.filter != oldWidget.filter) {
  //     _loadInitialMedicationRequests();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _loadInitialMedicationRequests();
        },
        color: Theme.of(context).primaryColor,
        child: BlocConsumer<MedicationRequestCubit, MedicationRequestState>(
          listener: (context, state) {
            // if (state is MedicationRequestError) {
            //   ShowToast.showToastError(message: state.error);
            // }
          },
          builder: (context, state) {
            if (state is MedicationRequestLoading && !state.isLoadMore) {
              return Center(child: LoadingPage());
            }

            final medicationRequests =
                state is MedicationRequestSuccess
                    ? state.paginatedResponse.paginatedData!.items
                    : [];
            final hasMore =
                state is MedicationRequestSuccess ? state.hasMore : false;

            if (medicationRequests.isEmpty) {
              return NotFoundDataPage();
            }

            return ListView.builder(
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildMedicationRequestCard(MedicationRequestModel request) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => MedicationRequestDetailsPage(
                    medicationRequestId: request.id.toString(),
                  ),
            ),
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
                  Icon(
                    Icons.receipt_long,
                    color: AppColors.primaryColor,
                    size: 40,
                  ),
                  const SizedBox(width: 17),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.reason ??
                              "medicationRequestCard.defaultReason".tr(context),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          request.note ??
                              "medicationRequestCard.noNotes".tr(context),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
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
