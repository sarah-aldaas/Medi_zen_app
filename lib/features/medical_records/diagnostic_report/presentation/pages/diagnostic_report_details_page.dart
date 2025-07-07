import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/theme/app_color.dart';
import 'package:medizen_app/features/medical_records/diagnostic_report/data/models/diagnostic_report_model.dart';

import '../../../../../base/widgets/loading_page.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../../encounter/data/models/encounter_model.dart';
import '../../../service_request/data/models/service_request_model.dart';
import '../cubit/diagnostic_report_cubit/diagnostic_report_cubit.dart';

class DiagnosticReportDetailsPage extends StatefulWidget {
  final String diagnosticReportId;

  const DiagnosticReportDetailsPage({super.key, required this.diagnosticReportId});

  @override
  State<DiagnosticReportDetailsPage> createState() => _DiagnosticReportDetailsPageState();
}

class _DiagnosticReportDetailsPageState extends State<DiagnosticReportDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<DiagnosticReportCubit>().getDiagnosticReportDetails(
      diagnosticReportId: widget.diagnosticReportId,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "diagnosticReportDetails",
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
      body: BlocConsumer<DiagnosticReportCubit, DiagnosticReportState>(
        listener: (context, state) {
          if (state is DiagnosticReportError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is DiagnosticReportDetailsSuccess) {
            return _buildDiagnosticReportDetails(state.diagnosticReport);
          } else if (state is DiagnosticReportLoading) {
            return const Center(child: LoadingPage());
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
                  const SizedBox(height: 20),
                  Text(
                    'failedToLoadReport',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.read<DiagnosticReportCubit>().getDiagnosticReportDetails(
                      diagnosticReportId: widget.diagnosticReportId,
                      context: context,
                    ),
                    icon: const Icon(Icons.refresh),
                    label: Text("retry"),
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

  Widget _buildDiagnosticReportDetails(DiagnosticReportModel report) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(context, report),
          const SizedBox(height: 16),
          _buildMainDetailsCard(context, report),
          const SizedBox(height: 16),

          if (report.conclusion != null || report.note != null) ...[
            _buildSectionHeader(context, 'results'),
            _buildResultsSection(context, report),
            const SizedBox(height: 16),
          ],

          if (report.condition != null) ...[
            _buildSectionHeader(context, 'relatedCondition'),
            _buildConditionSection(context, report),
            const SizedBox(height: 16),
          ],

          if (report.status != null) ...[
            _buildSectionHeader(context, 'status'),
            _buildStatusSection(context, report),
            const SizedBox(height: 16),
          ],

          if (report.condition?.encounters != null && report.condition!.encounters!.isNotEmpty) ...[
            _buildSectionHeader(context, 'relatedEncounters'),
            _buildEncountersSection(context, report),
            const SizedBox(height: 16),
          ],

          if (report.condition?.serviceRequests != null && report.condition!.serviceRequests!.isNotEmpty) ...[
            _buildSectionHeader(context, 'relatedServiceRequests'),
            _buildServiceRequestsSection(context, report),
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

  Widget _buildHeaderSection(BuildContext context, DiagnosticReportModel report) {
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
              Icons.assignment,
              size: 50,
              color: AppColors.primaryColor,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.name ?? 'unknownReport',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.green,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (report.status != null)
                    Chip(
                      backgroundColor: _getStatusColor(report.status!.code),
                      label: Text(
                        report.status!.display,
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

  Widget _buildMainDetailsCard(BuildContext context, DiagnosticReportModel report) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'overview'),
            const Divider(height: 10, thickness: 1.5, color: Colors.grey),
            const SizedBox(height: 8),

            if (report.name != null)
              _buildDetailRow(
                icon: Icons.description,
                label: 'reportName',
                value: report.name!,
                iconColor: Colors.blueAccent,
              ),

            if (report.condition != null)
              _buildDetailRow(
                icon: Icons.medical_services,
                label: 'relatedCondition',
                value: report.condition!.healthIssue ?? 'unknownCondition',
                iconColor: Colors.green,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection(BuildContext context, DiagnosticReportModel report) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (report.conclusion != null)
              _buildNoteItem(
                icon: Icons.assignment_turned_in,
                title: 'conclusion',
                content: report.conclusion!,
                color: Colors.teal,
              ),

            if (report.note != null)
              _buildNoteItem(
                icon: Icons.notes,
                title: 'notes',
                content: report.note!,
                color: Colors.deepOrange,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionSection(BuildContext context, DiagnosticReportModel report) {
    final condition = report.condition!;
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
              leading: Icon(
                Icons.medical_services,
                color: AppColors.primaryColor,
                size: 28,
              ),
              title: Text(
                condition.healthIssue ?? 'unknownCondition',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: condition.clinicalStatus != null
                  ? Text(
                condition.clinicalStatus!.display,
                style: TextStyle(
                  color: _getStatusColor(condition.clinicalStatus!.code),
                  fontWeight: FontWeight.bold,
                ),
              )
                  : null,
            ),

            const Divider(height: 20, thickness: 1, color: Colors.grey),

            // Condition Details
            if (condition.isChronic != null)
              _buildDetailRow(
                icon: Icons.timelapse,
                label: 'chronicCondition',
                value: condition.isChronic! ? 'yes' : 'no',
                iconColor: Colors.orange,
              ),

            if (condition.onSetDate != null)
              _buildDetailRow(
                icon: Icons.calendar_today,
                label: 'onsetDate',
                value: _formatDate(condition.onSetDate!),
                iconColor: Colors.purple,
              ),

            if (condition.recordDate != null)
              _buildDetailRow(
                icon: Icons.date_range,
                label: 'recordDate',
                value: _formatDate(condition.recordDate!),
                iconColor: Colors.blue,
              ),

            if (condition.verificationStatus != null)
              _buildDetailRow(
                icon: Icons.verified_user,
                label: 'verificationStatus',
                value: condition.verificationStatus!.display,
                iconColor: Colors.green,
              ),

            if (condition.bodySite != null)
              _buildDetailRow(
                icon: Icons.location_on,
                label: 'bodySite',
                value: condition.bodySite!.display,
                iconColor: Colors.deepPurple,
              ),

            if (condition.stage != null)
              _buildDetailRow(
                icon: Icons.stacked_line_chart,
                label: 'stage',
                value: condition.stage!.display,
                iconColor: Colors.amber,
              ),

            if (condition.summary != null && condition.summary!.isNotEmpty)
              _buildNoteItem(
                icon: Icons.summarize,
                title: 'summary',
                content: condition.summary!,
                color: Colors.teal,
              ),

            if (condition.extraNote != null && condition.extraNote!.isNotEmpty)
              _buildNoteItem(
                icon: Icons.note_add,
                title: 'additionalNotes',
                content: condition.extraNote!,
                color: Colors.deepOrange,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context, DiagnosticReportModel report) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              icon: Icons.info,
              label: 'status',
              value: report.status!.display,
              iconColor: _getStatusColor(report.status!.code),
            ),

            if (report.status!.description != null && report.status!.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  report.status!.description!,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEncountersSection(BuildContext context, DiagnosticReportModel report) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...report.condition!.encounters!.map((encounter) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildEncounterItem(context, encounter),
                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEncounterItem(BuildContext context, EncounterModel encounter) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    encounter.reason ?? 'unknownReason',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            if (encounter.actualStartDate != null)
              _buildDetailRow(
                icon: Icons.timer,
                label: 'startTime',
                value: _formatDateTime(encounter.actualStartDate!),
                iconColor: Colors.green,
                small: true,
              ),

            if (encounter.actualEndDate != null)
              _buildDetailRow(
                icon: Icons.timer_off,
                label: 'endTime',
                value: _formatDateTime(encounter.actualEndDate!),
                iconColor: Colors.red,
                small: true,
              ),

            if (encounter.specialArrangement != null && encounter.specialArrangement!.isNotEmpty)
              _buildDetailRow(
                icon: Icons.settings,
                label: 'specialArrangements',
                value: encounter.specialArrangement!,
                iconColor: Colors.blue,
                small: true,
              ),

            if (encounter.type != null)
              _buildDetailRow(
                icon: Icons.category,
                label: 'encounterType',
                value: encounter.type!.display,
                iconColor: Colors.purple,
                small: true,
              ),

            if (encounter.status != null)
              _buildDetailRow(
                icon: Icons.info,
                label: 'status',
                value: encounter.status!.display,
                iconColor: _getStatusColor(encounter.status!.code),
                small: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceRequestsSection(BuildContext context, DiagnosticReportModel report) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...report.condition!.serviceRequests!.map((request) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildServiceRequestItem(context, request),
                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceRequestItem(BuildContext context, ServiceRequestModel request) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_services, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    request.healthCareService?.name ?? 'unknownService',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            if (request.serviceRequestStatus != null)
              _buildDetailRow(
                icon: Icons.info,
                label: 'status',
                value: request.serviceRequestStatus!.display,
                iconColor: _getStatusColor(request.serviceRequestStatus!.code),
                small: true,
              ),

            if (request.orderDetails != null && request.orderDetails!.isNotEmpty)
              _buildDetailRow(
                icon: Icons.description,
                label: 'orderDetails',
                value: request.orderDetails!,
                iconColor: Colors.blue,
                small: true,
              ),

            if (request.reason != null && request.reason!.isNotEmpty)
              _buildDetailRow(
                icon: Icons.medical_information,
                label: 'reason',
                value: request.reason!,
                iconColor: Colors.green,
                small: true,
              ),

            if (request.note != null && request.note!.isNotEmpty)
              _buildDetailRow(
                icon: Icons.note,
                label: 'notes',
                value: request.note!,
                iconColor: Colors.deepOrange,
                small: true,
              ),

            if (request.occurrenceDate != null)
              _buildDetailRow(
                icon: Icons.date_range,
                label: 'occurrenceDate',
                value: DateFormat('MMM dd, yyyy').format(request.occurrenceDate!),
                iconColor: Colors.purple,
                small: true,
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
    bool small = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: small ? 20 : 24, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: small
                      ? Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  )
                      : Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: small
                      ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  )
                      : Theme.of(context).textTheme.bodyLarge?.copyWith(
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('MMM dd, yyyy - HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  Color _getStatusColor(String? statusCode) {
    switch (statusCode) {
      case 'final':
      case 'completed':
      case 'condition_confirmed':
      case 'service_request_active':
        return Colors.green;
      case 'partial':
      case 'service_request_pending':
        return Colors.orange;
      case 'preliminary':
        return Colors.blue;
      case 'amended':
        return Colors.purple;
      case 'corrected':
        return Colors.teal;
      case 'appended':
        return Colors.indigo;
      case 'cancelled':
      case 'service_request_cancelled':
        return Colors.red;
      case 'entered-in-error':
        return Colors.redAccent;
      case 'unknown':
        return Colors.grey;
      case 'condition_active':
        return Colors.green.shade700;
      case 'service_request_completed':
        return Colors.green.shade600;
      case 'service_request_rejected':
        return Colors.red.shade600;
      default:
        return Colors.grey;
    }
  }
}