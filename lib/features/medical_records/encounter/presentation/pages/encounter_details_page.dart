import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/go_router/go_router.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';

import '../../../../../base/data/models/code_type_model.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../data/models/encounter_model.dart';
import '../cubit/encounter_cubit/encounter_cubit.dart';
import '../widgets/service_list_item.dart';

class EncounterDetailsPage extends StatefulWidget {
  final String encounterId;

  const EncounterDetailsPage({super.key, required this.encounterId});

  @override
  State<EncounterDetailsPage> createState() => _EncounterDetailsPageState();
}

class _EncounterDetailsPageState extends State<EncounterDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<EncounterCubit>().getSpecificEncounter(
      encounterId: widget.encounterId,
      context: context
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'encountersPge.encounterDetails'.tr(context),
          style:
          theme.appBarTheme.titleTextStyle?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ) ??
              TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
        ),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 2,
        iconTheme: theme.appBarTheme.iconTheme,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocConsumer<EncounterCubit, EncounterState>(
        listener: (context, state) {
          if (state is EncounterError) {
            ShowToast.showToastError(message: '${'encountersPge.Error'.tr(context)}: ${state.error}');
          }
        },
        builder: (context, state) {
          if (state is EncounterLoading) {
            return Center(child: LoadingPage());
          } else if (state is EncounterDetailsSuccess) {
            return _buildEncounterDetails(context, state.encounterModel);
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 70,
                    color: theme.colorScheme.error.withOpacity(0.7),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'encountersPge.failedToLoad'.tr(context),
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.textTheme.bodySmall?.color,
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

  Widget _buildEncounterDetails(
      BuildContext context,
      EncounterModel encounter,
      ) {
    final ThemeData theme = Theme.of(context);
    final Color textColor = theme.textTheme.bodyLarge?.color ?? Colors.black87;
    final Color subTextColor =
        theme.textTheme.bodySmall?.color ?? Colors.grey.shade600;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  encounter.reason ??
                      'encountersPge.generalEncounter'.tr(
                        context,
                      ), // Translated
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              _buildStatusChip(encounter.status, context),
            ],
          ),
          const SizedBox(height: 30),
          _buildInfoCard(
            context,
            title: 'encountersPge.basicInformation'.tr(context),
            icon: Icons.info_outline,
            children: [
              _buildDetailRow(
                context,
                label: 'encountersPge.type'.tr(context),
                value: encounter.type?.display,
                icon: Icons.category_outlined,
              ),
              _buildDetailRow(
                context,
                label: 'encountersPge.status'.tr(context),
                value: encounter.status?.display,
                icon: Icons.check_circle_outline,
              ),
              if (encounter.actualStartDate != null)
                _buildDetailRow(
                  context,
                  label: 'encountersPge.startDate'.tr(context),
                  value: DateFormat(
                    'MMM d, y - h:mm a',
                  ).format(DateTime.parse(encounter.actualStartDate!)),
                  icon: Icons.calendar_today_outlined,
                ),
              if (encounter.actualEndDate != null)
                _buildDetailRow(
                  context,
                  label: 'encountersPge.endDate'.tr(context),
                  value: DateFormat(
                    'MMM d, y - h:mm a',
                  ).format(DateTime.parse(encounter.actualEndDate!)),
                  icon: Icons.calendar_today_outlined,
                ),
              if (encounter.specialArrangement?.isNotEmpty ?? false)
                _buildDetailRow(
                  context,
                  label: 'encountersPge.specialNotes'.tr(context),
                  value: encounter.specialArrangement,
                  icon: Icons.notes_outlined,
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (encounter.appointment != null) ...[
            _buildInfoCard(
              context,
              title: 'encountersPge.appointmentDetails'.tr(context),
              icon: Icons.schedule_outlined,
              actionWidget: IconButton(
                onPressed: () {
                  context
                      .pushNamed(
                    AppRouter.appointmentDetails.name,
                    extra: {"appointmentId": encounter.appointment!.id},
                  )
                      .then((value) {
                    context.read<EncounterCubit>().getSpecificEncounter(
                      encounterId: widget.encounterId,
                      context: context
                    );
                  });
                },
                icon: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: theme.primaryColor,
                    size: 15,
                  ),
                ),
                tooltip: 'encountersPge.GoAppointmentDetails'.tr(context),
              ),
              children: [
                _buildDetailRow(
                  context,
                  label: 'encountersPge.reason'.tr(context),
                  value: encounter.appointment?.reason,
                  icon: Icons.description_outlined,
                ),
                if (encounter.appointment?.startDate != null)
                  _buildDetailRow(
                    context,
                    label: 'encountersPge.scheduled'.tr(context),
                    value: DateFormat(
                      'MMM d, y - h:mm a',
                    ).format(DateTime.parse(encounter.appointment!.startDate!)),
                    icon: Icons.access_time_outlined,
                  ),
                if (encounter.appointment?.doctor != null)
                  _buildDetailRow(
                    context,
                    label: 'encountersPge.doctor'.tr(context),
                    value:
                    '${encounter.appointment?.doctor?.prefix ?? ''} ${encounter.appointment?.doctor?.fName ?? ''} ${encounter.appointment?.doctor?.lName ?? ''}'
                        .trim(),
                    icon: Icons.person_outline,
                  ),
              ],
            ),
            const SizedBox(height: 24),
          ],
          if (encounter.healthCareServices?.isNotEmpty ?? false)
            _buildInfoCard(
              context,
              title: 'encountersPge.servicesProvided'.tr(context),
              icon: Icons.medical_services_outlined,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: encounter.healthCareServices?.length ?? 0,
                  itemBuilder: (context, index) {
                    final service = encounter.healthCareServices![index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ServiceListItem(service: service),
                    );
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        Widget? actionWidget,
        required List<Widget> children,
      }) {
    final ThemeData theme = Theme.of(context);
    return Card(
      elevation: 6,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.primaryColor, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                if (actionWidget != null) actionWidget,
              ],
            ),
            Divider(height: 24, thickness: 1, color: theme.dividerColor),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context, {
        required String label,
        String? value,
        required IconData icon,
      }) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.primaryColor.withOpacity(0.7), size: 18),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodySmall?.color,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(CodeModel? status, BuildContext context) {
    final ThemeData theme = Theme.of(context);
    Color chipColor;
    Color textColor = theme.colorScheme.onPrimary;
    String getTranslatedStatus(String? statusCode) {
      switch (statusCode) {
        case 'planned':
          return 'encountersPge.planned'.tr(context);
        case 'in-progress':
          return 'encountersPge.inProgress'.tr(context);
        case 'completed':
          return 'encountersPge.completed'.tr(context);
        case 'cancelled':
          return 'encountersPge.cancelled'.tr(context);
        default:
          return 'encountersPge.unknownStatus'.tr(context);
      }
    }

    switch (status?.code) {
      case 'planned':
        chipColor = Colors.blue.shade600;
        break;
      case 'in-progress':
        chipColor = Colors.orange.shade600;
        break;
      case 'completed':
        chipColor = Colors.green.shade600;
        break;
      case 'cancelled':
        chipColor = Colors.red.shade600;
        break;
      default:
        chipColor =
            theme.textTheme.bodySmall?.color ??
                Colors.grey.shade500;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: chipColor.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        getTranslatedStatus(status?.code),
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
