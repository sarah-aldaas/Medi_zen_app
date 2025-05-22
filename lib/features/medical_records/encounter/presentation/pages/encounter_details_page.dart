import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/go_router/go_router.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';

import '../../../../../base/data/models/code_type_model.dart';
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
    context.read<EncounterCubit>().getSpecificEncounter(encounterId: widget.encounterId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Encounter Details')),
      body: BlocConsumer<EncounterCubit, EncounterState>(
        listener: (context, state) {
          if (state is EncounterError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          if (state is EncounterLoading) {
            return const Center(child: LoadingPage());
          } else if (state is EncounterDetailsSuccess) {
            return _buildEncounterDetails(state.encounterModel);
          } else {
            return const Center(child: Text('Failed to load encounter details'));
          }
        },
      ),
    );
  }

  Widget _buildEncounterDetails(EncounterModel encounter) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status indicator
          Row(
            children: [
              Expanded(child: Text(encounter.reason ?? 'Encounter', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold))),
              _buildStatusChip(encounter.status),
            ],
          ),
          const SizedBox(height: 16),

          // Basic Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Basic Information', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildDetailRow('Type', encounter.type?.display),
                  _buildDetailRow('Status', encounter.status?.display),
                  if (encounter.actualStartDate != null)
                    _buildDetailRow('Start', DateFormat('MMM d, y - h:mm a').format(DateTime.parse(encounter.actualStartDate!))),
                  if (encounter.actualEndDate != null) _buildDetailRow('End', DateFormat('MMM d, y - h:mm a').format(DateTime.parse(encounter.actualEndDate!))),
                  if (encounter.specialArrangement?.isNotEmpty ?? false) _buildDetailRow('Special Notes', encounter.specialArrangement),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Appointment Information
          if (encounter.appointment != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Appointment Information', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () {
                    context.pushNamed(AppRouter.appointmentDetails.name, extra: {"appointmentId": encounter.appointment!.id}).then((value){
                      context.read<EncounterCubit>().getSpecificEncounter(encounterId: widget.encounterId);

                    });
                  },
                  icon: Icon(Icons.arrow_circle_right, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Reason', encounter.appointment?.reason),
                    if (encounter.appointment?.startDate != null)
                      _buildDetailRow('Scheduled', DateFormat('MMM d, y - h:mm a').format(DateTime.parse(encounter.appointment!.startDate!))),
                    if (encounter.appointment?.doctor != null)
                      _buildDetailRow(
                        'Doctor',
                        '${encounter.appointment?.doctor?.prefix} ${encounter.appointment?.doctor?.fName} ${encounter.appointment?.doctor?.lName}',
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Services Section
          if (encounter.healthCareServices?.isNotEmpty ?? false) ...[
            Text('Services Provided', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: encounter.healthCareServices?.length ?? 0,
              itemBuilder: (context, index) {
                final service = encounter.healthCareServices![index];
                return ServiceListItem(service: service);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(child: Text(value ?? 'Not specified', style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildStatusChip(CodeModel? status) {
    Color chipColor;
    switch (status?.code) {
      case 'planned':
        chipColor = Colors.blue;
        break;
      case 'in-progress':
        chipColor = Colors.orange;
        break;
      case 'completed':
        chipColor = Colors.green;
        break;
      case 'cancelled':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(label: Text(status?.display ?? 'Unknown', style: const TextStyle(color: Colors.white)), backgroundColor: chipColor);
  }
}
