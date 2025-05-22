import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/medical_records/encounter/presentation/pages/encounter_details_page.dart';
import 'package:medizen_app/features/medical_records/reaction/presentation/pages/appointment_reactions_page.dart';

import '../../../../../base/data/models/code_type_model.dart';
import '../../data/models/allergy_model.dart';
import '../cubit/allergy_cubit/allergy_cubit.dart';

class AllergyDetailsPage extends StatefulWidget {
  final String allergyId;
  String? appointmentId=null;

  AllergyDetailsPage({super.key, required this.allergyId, this.appointmentId});

  @override
  State<AllergyDetailsPage> createState() => _AllergyDetailsPageState();
}

class _AllergyDetailsPageState extends State<AllergyDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<AllergyCubit>().getSpecificAllergy(allergyId: widget.allergyId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Allergy Details')),
      body: BlocConsumer<AllergyCubit, AllergyState>(
        listener: (context, state) {
          if (state is AllergyError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          if (state is AllergyLoading) {
            return const Center(child: LoadingPage());
          } else if (state is AllergyDetailsSuccess) {
            return _buildAllergyDetails(state.allergyModel);
          } else {
            return const Center(child: Text('Failed to load allergy details'));
          }
        },
      ),
    );
  }

  Widget _buildAllergyDetails(AllergyModel allergy) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with criticality indicator
          Row(
            children: [
              Expanded(child: Text(allergy.name ?? 'Unknown Allergy', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold))),
              _buildCriticalityChip(allergy.criticality),
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
                  _buildDetailRow('Type', allergy.type?.display),
                  _buildDetailRow('Category', allergy.category?.display),
                  _buildDetailRow('Clinical Status', allergy.clinicalStatus?.display),
                  _buildDetailRow('Verification', allergy.verificationStatus?.display),
                  _buildDetailRow('Onset Age', '${allergy.onSetAge} years'),
                  if (allergy.lastOccurrence != null)
                    _buildDetailRow('Last Occurrence', DateFormat('MMM d, y').format(DateTime.parse(allergy.lastOccurrence!))),
                  if (allergy.note?.isNotEmpty ?? false) _buildDetailRow('Notes', allergy.note),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Reactions Section
          if (widget.appointmentId == null && (allergy.reactions?.isNotEmpty ?? false)) ...[
            Text('Reactions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allergy.reactions?.length ?? 0,
              itemBuilder: (context, index) {
                final reaction = allergy.reactions![index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(reaction.manifestation ?? 'Unknown Reaction', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            _buildSeverityChip(reaction.severity),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow('Substance', reaction.substance),
                        _buildDetailRow('Exposure Route', reaction.exposureRoute?.display),
                        if (reaction.onSet != null) _buildDetailRow('Onset', DateFormat('MMM d, y - h:mm a').format(DateTime.parse(reaction.onSet!))),
                        if (reaction.description?.isNotEmpty ?? false) _buildDetailRow('Description', reaction.description),
                        if (reaction.note?.isNotEmpty ?? false) _buildDetailRow('Notes', reaction.note),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
          if (widget.appointmentId != null) ...[
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text("Reactions"),
                trailing: Icon(Icons.arrow_circle_right, color: Colors.blue),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AppointmentReactionsPage(appointmentId: widget.appointmentId!, allergyId: widget.allergyId)),
                  ).then((value){
                    context.read<AllergyCubit>().getSpecificAllergy(allergyId: widget.allergyId);

                  });
                },
              ),
            ),
            Divider(),
          ],

          // Encounter Information
          if (allergy.encounter != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Encounter Information', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => EncounterDetailsPage(encounterId: allergy.encounter!.id!))).then((value){
                              context.read<AllergyCubit>().getSpecificAllergy(allergyId: widget.allergyId);

                            });
                          },
                          icon: Icon(Icons.arrow_circle_right, color: Colors.blue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow('Reason', allergy.encounter?.reason),
                    if (allergy.encounter?.actualStartDate != null)
                      _buildDetailRow('Date', DateFormat('MMM d, y - h:mm a').format(DateTime.parse(allergy.encounter!.actualStartDate!))),
                    if (allergy.encounter?.specialArrangement?.isNotEmpty ?? false) _buildDetailRow('Special Notes', allergy.encounter?.specialArrangement),
                  ],
                ),
              ),
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

  Widget _buildCriticalityChip(CodeModel? criticality) {
    Color chipColor;
    switch (criticality?.code) {
      case 'high':
        chipColor = Colors.red;
        break;
      case 'moderate':
        chipColor = Colors.orange;
        break;
      case 'low':
        chipColor = Colors.green;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(label: Text(criticality?.display ?? 'Unknown', style: const TextStyle(color: Colors.white)), backgroundColor: chipColor);
  }

  Widget _buildSeverityChip(CodeModel? severity) {
    Color chipColor;
    switch (severity?.code) {
      case 'mild':
        chipColor = Colors.green;
        break;
      case 'moderate':
        chipColor = Colors.orange;
        break;
      case 'severe':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(severity?.display ?? 'Unknown', style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: chipColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
