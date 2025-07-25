import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/theme/app_color.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/base/widgets/not_found_data_page.dart';
import 'package:medizen_app/features/medical_records/diagnostic_report/data/models/diagnostic_report_filter_model.dart';
import 'package:medizen_app/features/medical_records/diagnostic_report/data/models/diagnostic_report_model.dart';
import 'package:medizen_app/features/medical_records/diagnostic_report/presentation/pages/diagnostic_report_details_page.dart';

import '../cubit/diagnostic_report_cubit/diagnostic_report_cubit.dart';

class DiagnosticReportListOfAppointmentPage extends StatefulWidget {
  final DiagnosticReportFilterModel filter;
  final String appointmentId;
  final String conditionId;

  const DiagnosticReportListOfAppointmentPage({
    super.key,
    required this.filter,
    required this.appointmentId,
    required this.conditionId,
  });

  @override
  _DiagnosticReportListOfAppointmentPageState createState() =>
      _DiagnosticReportListOfAppointmentPageState();
}

class _DiagnosticReportListOfAppointmentPageState
    extends State<DiagnosticReportListOfAppointmentPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialReports();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DiagnosticReportListOfAppointmentPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.filter != oldWidget.filter) {
      _loadInitialReports();
    }
  }

  void _loadInitialReports() {
    _isLoadingMore = false;
    context.read<DiagnosticReportCubit>().getDiagnosticReportsForAppointment(
      context: context,
      filters: widget.filter.toJson(),
      appointmentId: widget.appointmentId,
      conditionId: widget.conditionId,
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context
          .read<DiagnosticReportCubit>()
          .getDiagnosticReportsForAppointment(
            loadMore: true,
            context: context,
            appointmentId: widget.appointmentId,
            filters: widget.filter.toJson(),
            conditionId: widget.conditionId,
          )
          .then((_) => setState(() => _isLoadingMore = false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _loadInitialReports();
        },
        color: Theme.of(context).primaryColor,
        child: BlocConsumer<DiagnosticReportCubit, DiagnosticReportState>(
          listener: (context, state) {
            // if (state is DiagnosticReportError) {
            //   ShowToast.showToastError(message: state.error);
            // }
          },
          builder: (context, state) {
            if (state is DiagnosticReportLoading && !state.isLoadMore) {
              return const Center(child: LoadingPage());
            }

            final reports =
                state is DiagnosticReportSuccess
                    ? state.paginatedResponse.paginatedData!.items
                    : [];
            final hasMore =
                state is DiagnosticReportSuccess ? state.hasMore : false;

            if (reports.isEmpty) {
              return NotFoundDataPage();
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              itemCount: reports.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < reports.length) {
                  return _buildReportItem(reports[index]);
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

  Widget _buildReportItem(DiagnosticReportModel report) {
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
                    (context) => DiagnosticReportDetailsPage(
                      diagnosticReportId: report.id!,
                    ),
              ),
            ).then((value) {
              _loadInitialReports();
            }),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon(
                  //   Icons.assignment,
                  //   color: AppColors.primaryColor,
                  //   size: 28,
                  // ),
                  // const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      report.name ??
                          'diagnosticListAppointmentPage.diagnosticReportListAppointment_unnamedReport'
                              .tr(context),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.green),
                ],
              ),
              Divider(),
              const Gap(10),

              if (report.note != null && report.note!.isNotEmpty)
                _buildInfoRow(
                  icon: Icons.note,
                  label:
                      'diagnosticListAppointmentPage.diagnosticReportListAppointment_note'
                          .tr(context),
                  value: report.note!,
                  color: Theme.of(context).primaryColor,
                ),

              if (report.condition != null) ...[
                _buildInfoRow(
                  icon: Icons.medical_services,
                  label:
                      'diagnosticListAppointmentPage.diagnosticReportListAppointment_condition'
                          .tr(context),
                  value:
                      report.condition!.healthIssue ??
                      'diagnosticListAppointmentPage.diagnosticReportListAppointment_unknownCondition'
                          .tr(context),
                  color: Theme.of(context).primaryColor,
                ),

                if (report.condition!.clinicalStatus != null)
                  _buildInfoRow(
                    icon: Icons.info_outline,
                    label:
                        'diagnosticListAppointmentPage.diagnosticReportListAppointment_clinicalStatus'
                            .tr(context),
                    value: report.condition!.clinicalStatus!.display,
                    color: _getStatusColor(
                      report.condition!.clinicalStatus!.code,
                    ),
                  ),

                if (report.condition!.verificationStatus != null)
                  _buildInfoRow(
                    icon: Icons.verified,
                    label:
                        'diagnosticListAppointmentPage.diagnosticReportListAppointment_verificationStatus'
                            .tr(context),
                    value: report.condition!.verificationStatus!.display,
                    color: _getStatusColor(
                      report.condition!.verificationStatus!.code,
                    ),
                  ),

                if (report.condition!.bodySite != null)
                  _buildInfoRow(
                    icon: Icons.location_on,
                    label:
                        'diagnosticListAppointmentPage.diagnosticReportListAppointment_bodySite'
                            .tr(context),
                    value: report.condition!.bodySite!.display,
                    color: Theme.of(context).primaryColor,
                  ),

                if (report.condition!.stage != null)
                  _buildInfoRow(
                    icon: Icons.meeting_room_rounded,
                    label:
                        'diagnosticListAppointmentPage.diagnosticReportListAppointment_stage'
                            .tr(context),
                    value: report.condition!.stage!.display,
                    color: Theme.of(context).primaryColor,
                  ),

                if (report.condition!.onSetDate != null)
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label:
                        'diagnosticListAppointmentPage.diagnosticReportListAppointment_onset_date'
                            .tr(context),
                    value: _formatDate(report.condition!.onSetDate!),
                    color: Theme.of(context).primaryColor,
                  ),
              ],

              if (report.conclusion != null && report.conclusion!.isNotEmpty)
                _buildInfoRow(
                  icon: Icons.assignment_turned_in,
                  label:
                      'diagnosticListAppointmentPage.diagnosticReportListAppointment_conclusion'
                          .tr(context),
                  value: report.conclusion!,
                  color: Theme.of(context).primaryColor,
                  maxLines: 3,
                ),

              if (report.status != null)
                _buildInfoRow(
                  icon: Icons.star,
                  label:
                      'diagnosticListAppointmentPage.diagnosticReportListAppointment_reportStatus'
                          .tr(context),
                  value: report.status!.display,
                  color: _getStatusColor(report.status!.code),
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).primaryColor),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.label,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('MMM dd,EEEE').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  Color _getStatusColor(String? statusCode) {
    switch (statusCode) {
      case 'diagnostic_report_final':
        return Colors.green;

      case 'diagnostic_report_registered':
        return Colors.blue;

      case 'diagnostic_report_cancelled':
        return Colors.red;
      case 'unknown':
      default:
        return Colors.grey;
    }
  }
}
