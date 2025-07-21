import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/medical_records/conditions/data/models/conditions_model.dart';
import 'package:medizen_app/features/medical_records/conditions/presentation/pages/condition_details_page.dart';

import '../../../../../base/theme/app_color.dart';
import '../../../../../base/widgets/not_found_data_page.dart';
import '../../data/models/conditions_filter_model.dart';
import '../cubit/condition_cubit/conditions_cubit.dart';

class ConditionsListPage extends StatefulWidget {
  final ConditionsFilterModel filter;

  const ConditionsListPage({super.key, required this.filter});

  @override
  _ConditionsListPageState createState() => _ConditionsListPageState();
}

class _ConditionsListPageState extends State<ConditionsListPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialConditions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ConditionsListPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.filter != oldWidget.filter) {
      _loadInitialConditions();
    }
  }

  void _loadInitialConditions() {
    _isLoadingMore = false;
    context.read<ConditionsCubit>().getAllConditions(
      context: context,
      filters: widget.filter.toJson(),
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context
          .read<ConditionsCubit>()
          .getAllConditions(
            loadMore: true,
            context: context,
            filters: widget.filter.toJson(),
          )
          .then((_) => setState(() => _isLoadingMore = false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _loadInitialConditions();
        },
        color: Theme.of(context).primaryColor,
        child: BlocConsumer<ConditionsCubit, ConditionsState>(
          listener: (context, state) {

          },
          builder: (context, state) {
            if (state is ConditionsLoading && !state.isLoadMore) {
              return const Center(child: LoadingPage());
            }

            final conditions =
                state is ConditionsSuccess
                    ? state.paginatedResponse.paginatedData!.items
                    : [];
            final hasMore = state is ConditionsSuccess ? state.hasMore : false;

            if (conditions.isEmpty) {
              return NotFoundDataPage();
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: conditions.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < conditions.length) {
                  return _buildConditionItem(conditions[index]);
                } else {
                  return Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: LoadingButton()),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildConditionItem(ConditionsModel condition) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        ConditionDetailsPage(conditionId: condition.id!),
              ),
            ).then((value) {
              _loadInitialConditions();
            }),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [

                  Expanded(
                    child: Text(
                      condition.healthIssue ??
                          'conditionsList.unknownCondition'.tr(context),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.green),
                ],
              ),
              Divider(height: 20, thickness: 1, color: Colors.grey[200]),
              const Gap(10),
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: 'conditionsList.onsetDate'.tr(context),
                value:
                    condition.onSetDate != null
                        ? DateFormat(
                          'MMM d, y',
                        ).format(DateTime.parse(condition.onSetDate!))
                        : 'conditionsList.notAvailable'.tr(context),
                color: Theme.of(context).primaryColor,
              ),
              if (condition.clinicalStatus != null)
                _buildInfoRow(
                  icon: Icons.monitor_heart,
                  label: 'conditionsList.clinicalStatus'.tr(context),
                  value: condition.clinicalStatus!.display,
                  color: Theme.of(context).primaryColor,
                ),
              if (condition.verificationStatus != null)
                _buildInfoRow(
                  icon: Icons.verified,
                  label: 'conditionsList.verification'.tr(context),
                  value: condition.verificationStatus!.display,
                  color: Theme.of(context).primaryColor,
                ),
              if (condition.stage != null)
                _buildInfoRow(
                  icon: Icons.meeting_room_rounded,
                  label: 'conditionsList.stage'.tr(context),
                  value: condition.stage!.display,
                  color: Theme.of(context).primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    int maxLines = 2,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    '$label:',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.label,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value,
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
