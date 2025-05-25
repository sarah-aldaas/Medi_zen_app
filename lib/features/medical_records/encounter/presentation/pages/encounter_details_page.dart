import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/go_router/go_router.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';

import '../../../../../base/data/models/code_type_model.dart';
import '../../../../../base/theme/app_color.dart';
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Encounter Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: AppColors.primaryColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.whiteColor,
        elevation: 2,
      ),
      body: BlocConsumer<EncounterCubit, EncounterState>(
        listener: (context, state) {
          if (state is EncounterError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is EncounterLoading) {
            return const Center(child: LoadingPage());
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
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load encounter details',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
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
                  encounter.reason ?? 'General Encounter',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),

              _buildStatusChip(encounter.status),
            ],
          ),
          const SizedBox(height: 30),

          _buildInfoCard(
            context,
            title: 'Basic Information',
            icon: Icons.info_outline,
            children: [
              _buildDetailRow(
                context,
                label: 'Type',
                value: encounter.type?.display,
                icon: Icons.category_outlined,
              ),
              _buildDetailRow(
                context,
                label: 'Status',
                value: encounter.status?.display,
                icon: Icons.check_circle_outline,
              ),
              if (encounter.actualStartDate != null)
                _buildDetailRow(
                  context,
                  label: 'Start Date',
                  value: DateFormat(
                    'MMM d, y - h:mm a',
                  ).format(DateTime.parse(encounter.actualStartDate!)),
                  icon: Icons.calendar_today_outlined,
                ),
              if (encounter.actualEndDate != null)
                _buildDetailRow(
                  context,
                  label: 'End Date',
                  value: DateFormat(
                    'MMM d, y - h:mm a',
                  ).format(DateTime.parse(encounter.actualEndDate!)),
                  icon: Icons.calendar_today_outlined,
                ),
              if (encounter.specialArrangement?.isNotEmpty ?? false)
                _buildDetailRow(
                  context,
                  label: 'Special Notes',
                  value: encounter.specialArrangement,
                  icon: Icons.notes_outlined,
                ),
            ],
          ),
          const SizedBox(height: 24),

          if (encounter.appointment != null) ...[
            _buildInfoCard(
              context,
              title: 'Appointment Details',
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
                        );
                      });
                },
                icon: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.15),
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
                    color: Theme.of(context).primaryColor,
                    size: 15,
                  ),
                ),
                tooltip: 'Go to Appointment Details',
              ),
              children: [
                _buildDetailRow(
                  context,
                  label: 'Reason',
                  value: encounter.appointment?.reason,
                  icon: Icons.description_outlined,
                ),
                if (encounter.appointment?.startDate != null)
                  _buildDetailRow(
                    context,
                    label: 'Scheduled',
                    value: DateFormat(
                      'MMM d, y - h:mm a',
                    ).format(DateTime.parse(encounter.appointment!.startDate!)),
                    icon: Icons.access_time_outlined,
                  ),
                if (encounter.appointment?.doctor != null)
                  _buildDetailRow(
                    context,
                    label: 'Doctor',
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
              title: 'Services Provided',
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
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (actionWidget != null) actionWidget,
              ],
            ),
            const Divider(height: 24, thickness: 1),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor.withOpacity(0.7),
            size: 18,
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(CodeModel? status) {
    Color chipColor;
    Color textColor = Colors.white;

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
        chipColor = Colors.grey.shade500;
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
        status?.display ?? 'Unknown',
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
