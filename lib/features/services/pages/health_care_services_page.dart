import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/constant/app_images.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/go_router/go_router.dart';
import 'package:medizen_app/base/widgets/not_found_data_page.dart';
import 'package:medizen_app/features/services/data/model/health_care_services_model.dart';
import 'package:medizen_app/features/services/pages/widgets/health_care_service_filter_dialog.dart';

import '../../../base/theme/app_color.dart';
import '../../../base/widgets/loading_page.dart';
import '../../../base/widgets/show_toast.dart';
import '../data/model/health_care_service_filter.dart';
import 'cubits/service_cubit/service_cubit.dart';

class HealthCareServicesPage extends StatefulWidget {
  const HealthCareServicesPage({super.key});

  @override
  State<HealthCareServicesPage> createState() => _HealthCareServicesPageState();
}

class _HealthCareServicesPageState extends State<HealthCareServicesPage> {
  final ScrollController _scrollController = ScrollController();
  HealthCareServiceFilter _filter = HealthCareServiceFilter();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialServices();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialServices() {
    _isLoadingMore = false;
    context.read<ServiceCubit>().getAllServiceHealthCare(
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
          .read<ServiceCubit>()
          .getAllServiceHealthCare(filters: _filter.toJson(), loadMore: true,context: context)
          .then((_) {
        setState(() => _isLoadingMore = false);
      });
    }
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<HealthCareServiceFilter>(
      context: context,
      builder:
          (context) => HealthCareServiceFilterDialog(currentFilter: _filter),
    );

    if (result != null) {
      setState(() => _filter = result);
      _loadInitialServices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'healthCareServicesPage.title'.tr(context),

          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: _showFilterDialog,
            tooltip: 'healthCareServicesPage.filterTooltip'.tr(context),
          ),
        ],
      ),

      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocConsumer<ServiceCubit, ServiceState>(
        listener: (context, state) {
          if (state is ServiceHealthCareError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is ServiceHealthCareLoading && !state.isLoadMore) {
            return Center(child: LoadingPage());
          }

          final services =
          state is ServiceHealthCareSuccess
              ? state.paginatedResponse.paginatedData!.items
              : [];
          final hasMore =
          state is ServiceHealthCareSuccess ? state.hasMore : false;
          if (services.isEmpty) {
            return NotFoundDataPage();
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: services.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < services.length) {
                return _buildServiceItem(context, services[index]);
              } else if (hasMore && state is! ServiceHealthCareError) {
                return Center(
                  child: LoadingButton(
                    isWhite: Theme.of(context).brightness == Brightness.dark,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Widget _buildServiceItem(
      BuildContext context,
      HealthCareServiceModel service,
      ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      elevation: 2.0,

      color: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () {
          context
              .pushNamed(
            AppRouter.healthServiceDetails.name,
            extra: {"serviceId": service.id.toString()},
          )
              .then((value) {
            _loadInitialServices();
          });
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      AppAssetImages.article2,
                      width: 110,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Icon(
                        Icons.image_not_supported_outlined,
                        size: 40,
                        color: Theme.of(
                          context,
                        ).iconTheme.color?.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        service.name ??
                            'healthCareServicesPage.unnamedService'.tr(context),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,

                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        service.comment ??
                            'healthCareServicesPage.noDescriptionAvailable'.tr(
                              context,
                            ),
                        style: TextStyle(
                          fontSize: 14,

                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        '${'healthCareServicesPage.price'.tr(context)}: \$${service.price ?? 'N/A'}',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(height: 18.0),
                      if (service.category != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            service.category!.display,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
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
