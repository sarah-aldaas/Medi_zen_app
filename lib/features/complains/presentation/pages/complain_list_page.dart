import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/theme/app_color.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import 'package:medizen_app/features/complains/data/models/complain_filter_model.dart';
import 'package:medizen_app/features/complains/data/models/complain_model.dart';

import '../cubit/complain_cubit/complain_cubit.dart';
import '../widgets/complain_filter_dialog.dart';
import 'complain_details_page.dart';

class ComplainListPage extends StatefulWidget {
  const ComplainListPage({super.key});

  @override
  _ComplainListPageState createState() => _ComplainListPageState();
}

class _ComplainListPageState extends State<ComplainListPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  ComplainFilterModel _filter = ComplainFilterModel();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialComplains();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialComplains() {
    _isLoadingMore = false;
    context.read<ComplainCubit>().getAllComplains(
      context: context,
      filters: _filter.toJson(),
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context
          .read<ComplainCubit>()
          .getAllComplains(
            loadMore: true,
            context: context,
            filters: _filter.toJson(),
          )
          .then((_) => setState(() => _isLoadingMore = false));
    }
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<ComplainFilterModel>(
      context: context,
      builder: (context) => ComplainFilterDialog(currentFilter: _filter),
    );

    if (result != null) {
      setState(() => _filter = result);
      _loadInitialComplains();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'complaintList.myComplaints'.tr(context),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: AppColors.primaryColor,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: AppColors.primaryColor),
            onPressed: _showFilterDialog,
            tooltip: 'complaintList.filterComplaints'.tr(context),
          ),
        ],
      ),
      body: BlocConsumer<ComplainCubit, ComplainState>(
        listener: (context, state) {
          if (state is ComplainError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is ComplainLoading && !state.isLoadMore) {
            return const Center(child: LoadingPage());
          }

          final complains =
              state is ComplainSuccess
                  ? state.paginatedResponse.paginatedData!.items
                  : [];
          final hasMore = state is ComplainSuccess ? state.hasMore : false;

          if (complains.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 80,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.6),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'complaintList.noComplaintsFound'.tr(context),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: Colors.grey.shade700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'complaintList.adjustFiltersMessage'.tr(context),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _loadInitialComplains,
                      icon: Icon(Icons.refresh, color: AppColors.whiteColor),
                      label: Text('complaintList.refreshList'.tr(context)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadInitialComplains(),
            color: Theme.of(context).colorScheme.secondary,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: complains.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < complains.length) {
                  return _buildComplainItem(context, complains[index]);
                } else {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildComplainItem(BuildContext context, ComplainModel complain) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ComplainDetailsPage(complainId: complain.id!),
              ),
            ).then((_) => _loadInitialComplains()),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                complain.title ?? 'complaintList.noTitle'.tr(context),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              if (complain.description != null &&
                  complain.description!.isNotEmpty)
                Text(
                  complain.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (complain.status != null)
                    _buildStatusChip(context, complain.status!),
                  if (complain.type != null)
                    _buildTypeChip(context, complain.type!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, status) {
    return Chip(
      label: Text(
        status.display,
        style: TextStyle(
          color: _getStatusTextColor(status.code),
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: _getStatusColor(status.code).withOpacity(0.2),
      side: BorderSide(color: _getStatusColor(status.code)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
  }

  Widget _buildTypeChip(BuildContext context, type) {
    return Chip(
      label: Text(
        type.display,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: Colors.blueGrey.shade400,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
  }

  Color _getStatusColor(String? statusCode) {
    switch (statusCode) {
      case 'complaint_new':
        return Colors.lightGreen.shade400;
      case 'complaint_in_review':
        return Colors.blue.shade700;
      case 'complaint_resolved':
        return Colors.green.shade700;
      case 'complaint_closed':
        return Colors.blueGrey.shade600;
      case 'complaint_rejected':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade500;
    }
  }

  Color _getStatusTextColor(String? statusCode) {
    switch (statusCode) {
      case 'complaint_new':
        return Colors.lightGreen.shade900;
      case 'complaint_in_review':
        return Colors.blue.shade900;
      case 'complaint_resolved':
        return Colors.green.shade900;
      case 'complaint_closed':
        return Colors.blueGrey.shade900;
      case 'complaint_rejected':
        return Colors.red.shade900;
      default:
        return Colors.grey.shade800;
    }
  }
}
