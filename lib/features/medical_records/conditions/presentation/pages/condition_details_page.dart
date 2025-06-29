import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/theme/app_color.dart';
import 'package:medizen_app/features/medical_records/conditions/data/models/conditions_model.dart';

import '../../../../../base/widgets/loading_page.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../cubit/condition_cubit/conditions_cubit.dart';

class ConditionDetailsPage extends StatefulWidget {
  final String conditionId;

  const ConditionDetailsPage({super.key, required this.conditionId});

  @override
  State<ConditionDetailsPage> createState() => _ConditionDetailsPageState();
}

class _ConditionDetailsPageState extends State<ConditionDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ConditionsCubit>().getConditionDetails(
      conditionId: widget.conditionId,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "conditionDetails.title".tr(context),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
            fontSize: 22,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<ConditionsCubit, ConditionsState>(
        listener: (context, state) {
          if (state is ConditionsError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is ConditionDetailsSuccess) {
            return _buildConditionDetails(state.condition);
          } else if (state is ConditionsLoading) {
            return const Center(child: LoadingPage());
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
                  const SizedBox(height: 20),
                  Text(
                    'conditionDetails.failedToLoad'.tr(context),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed:
                        () =>
                            context.read<ConditionsCubit>().getConditionDetails(
                              conditionId: widget.conditionId,
                              context: context,
                            ),
                    icon: const Icon(Icons.refresh),
                    label: Text("conditionDetails.retry".tr(context)),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildConditionDetails(ConditionsModel condition) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(context, condition),
          const SizedBox(height: 16),

          _buildMainDetailsCard(context, condition),
          const SizedBox(height: 16),

          if (condition.onSetDate != null ||
              condition.abatementDate != null ||
              condition.recordDate != null) ...[
            _buildSectionHeader(
              context,
              'conditionDetails.timeline'.tr(context),
            ),
            _buildTimelineSection(context, condition),
            const SizedBox(height: 16),
          ],

          if (condition.bodySite != null) ...[
            _buildSectionHeader(
              context,
              'conditionDetails.bodySite'.tr(context),
            ),
            _buildBodySiteSection(context, condition),
            const SizedBox(height: 16),
          ],

          _buildSectionHeader(
            context,
            'conditionDetails.clinicalInformation'.tr(context),
          ),
          _buildClinicalInfoSection(context, condition),
          const SizedBox(height: 16),

          if (condition.encounters != null &&
              condition.encounters!.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              'conditionDetails.relatedEncounters'.tr(context),
            ),
            _buildEncountersSection(context, condition),
            const SizedBox(height: 16),
          ],

          if (condition.serviceRequests != null &&
              condition.serviceRequests!.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              'conditionDetails.relatedServiceRequests'.tr(context),
            ),
            _buildServiceRequestsSection(context, condition),
            const SizedBox(height: 16),
          ],

          if (condition.note != null ||
              condition.summary != null ||
              condition.extraNote != null) ...[
            _buildSectionHeader(context, 'conditionDetails.notes'.tr(context)),
            _buildNotesSection(context, condition),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.titel,
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, ConditionsModel condition) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.health_and_safety,
              size: 50,
              color: AppColors.primaryColor,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    condition.healthIssue ??
                        'conditionDetails.unknownCondition'.tr(context),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.green,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (condition.clinicalStatus != null)
                    Chip(
                      backgroundColor: _getStatusColor(
                        condition.clinicalStatus!.code,
                      ),
                      label: Text(
                        condition.clinicalStatus!.display,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainDetailsCard(
    BuildContext context,
    ConditionsModel condition,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              'conditionDetails.overview'.tr(context),
            ),
            const Divider(height: 10, thickness: 1.5, color: Colors.grey),
            const SizedBox(height: 8),

            _buildDetailRow(
              icon: Icons.calendar_month,
              label: 'conditionDetails.type'.tr(context),
              value:
                  condition.isChronic != null
                      ? (condition.isChronic!
                          ? 'conditionDetails.chronic'.tr(context)
                          : 'conditionDetails.acute'.tr(context))
                      : 'conditionDetails.notSpecified'.tr(context),
              iconColor: Colors.blueAccent,
            ),

            if (condition.verificationStatus != null)
              _buildDetailRow(
                icon: Icons.verified_user,
                label: 'conditionDetails.verification'.tr(context),
                value: condition.verificationStatus!.display,
                iconColor: Colors.green,
              ),

            if (condition.stage != null)
              _buildDetailRow(
                icon: Icons.insights,
                label: 'conditionDetails.stage'.tr(context),
                value: condition.stage!.display,
                iconColor: Colors.orange,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSection(
    BuildContext context,
    ConditionsModel condition,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (condition.onSetDate != null)
              _buildTimelineItem(
                icon: Icons.history,
                title: 'conditionDetails.onsetDate'.tr(context),
                date: DateFormat(
                  'MMM d, y',
                ).format(DateTime.parse(condition.onSetDate!)),
                age: condition.onSetAge,
                color: Colors.purple,
              ),

            if (condition.abatementDate != null)
              _buildTimelineItem(
                icon: Icons.check_circle_outline,
                title: 'conditionDetails.abatementDate'.tr(context),
                date: DateFormat(
                  'MMM d, y',
                ).format(DateTime.parse(condition.abatementDate!)),
                age: condition.abatementAge,
                color: Colors.teal,
              ),

            if (condition.recordDate != null)
              _buildTimelineItem(
                icon: Icons.assignment,
                title: 'conditionDetails.recordedDate'.tr(context),
                date: DateFormat(
                  'MMM d, y',
                ).format(DateTime.parse(condition.recordDate!)),
                color: Colors.indigo,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodySiteSection(
    BuildContext context,
    ConditionsModel condition,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.location_on,
                color: Colors.redAccent,
                size: 28,
              ),
              title: Text(
                condition.bodySite!.display,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle:
                  condition.bodySite!.description != null
                      ? Text(
                        condition.bodySite!.description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      )
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicalInfoSection(
    BuildContext context,
    ConditionsModel condition,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (condition.clinicalStatus != null)
              _buildDetailRow(
                icon: Icons.local_hospital,
                label: 'conditionDetails.clinicalStatus'.tr(context),
                value: condition.clinicalStatus!.display,
                iconColor: Colors.blueAccent,
              ),

            if (condition.verificationStatus != null)
              _buildDetailRow(
                icon: Icons.verified_outlined,
                label: 'conditionDetails.verificationStatus'.tr(context),
                value: condition.verificationStatus!.display,
                iconColor: Colors.deepOrange,
              ),

            if (condition.stage != null)
              _buildDetailRow(
                icon: Icons.bar_chart,
                label: 'conditionDetails.stage'.tr(context),
                value: condition.stage!.display,
                iconColor: Colors.greenAccent,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEncountersSection(
    BuildContext context,
    ConditionsModel condition,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...condition.encounters!
                .map(
                  (encounter) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.event_note,
                        color: Colors.indigo,
                        size: 28,
                      ),
                      title: Text(
                        encounter.reason ??
                            'conditionDetails.unknownReason'.tr(context),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        encounter.actualStartDate != null
                            ? DateFormat(
                              'MMM d, y, hh:mm a',
                            ).format(DateTime.parse(encounter.actualStartDate!))
                            : 'conditionDetails.noDateProvided'.tr(context),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        ShowToast.showToastInfo(
                          message: "conditionDetails.encounterDetailsToast".tr(
                            context,
                          ),
                        );
                      },
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceRequestsSection(
    BuildContext context,
    ConditionsModel condition,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...condition.serviceRequests!
                .map(
                  (request) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.medical_services,
                        color: AppColors.primaryColor,
                        size: 28,
                      ),
                      title: Text(
                        request.healthCareService?.name ??
                            'conditionDetails.unknownService'.tr(context),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        request.serviceRequestStatus?.display ??
                            'conditionDetails.unknownStatus'.tr(context),
                        style: TextStyle(
                          color: _getStatusColor(
                            request.serviceRequestStatus?.code,
                          ),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        ShowToast.showToastInfo(
                          message: "conditionDetails.serviceRequestDetailsToast"
                              .tr(context),
                        );
                      },
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context, ConditionsModel condition) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (condition.summary != null)
              _buildNoteItem(
                icon: Icons.summarize,
                title: 'conditionDetails.summary'.tr(context),
                content: condition.summary!,
                color: Colors.blueGrey,
              ),

            if (condition.note != null)
              _buildNoteItem(
                icon: Icons.note_alt,
                title: 'conditionDetails.notesLabel'.tr(context),
                content: condition.note!,
                color: Colors.deepOrange,
              ),

            if (condition.extraNote != null)
              _buildNoteItem(
                icon: Icons.bookmark_add,
                title: 'conditionDetails.additionalNotes'.tr(context),
                content: condition.extraNote!,
                color: Colors.teal,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String date,
    String? age,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      date,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    if (age != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        'conditionDetails.yearsAge'.tr(context),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteItem({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? statusCode) {
    switch (statusCode) {
      case 'active':
      case 'in-progress':
        return Colors.blue;
      case 'recurrence':
      case 'relapse':
        return Colors.orange;
      case 'inactive':
      case 'remission':
      case 'resolved':
        return AppColors.secondaryColor;
      case 'completed':
        return Colors.purple;
      case 'entered-in-error':
        return AppColors.red;
      default:
        return Colors.grey;
    }
  }
}
