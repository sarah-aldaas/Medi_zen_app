import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/medical_records/encounter/presentation/pages/encounter_details_page.dart';
import 'package:medizen_app/features/medical_records/reaction/presentation/pages/appointment_reactions_page.dart';

import '../../../../../base/data/models/code_type_model.dart';
import '../../../../../base/theme/app_color.dart';
import '../../../reaction/presentation/pages/reaction_details_page.dart';
import '../../../reaction/presentation/widgets/reaction_list_item.dart';
import '../../data/models/allergy_model.dart';
import '../cubit/allergy_cubit/allergy_cubit.dart';

class AllergyDetailsPage extends StatefulWidget {
  final String allergyId;
  final String? appointmentId;

  const AllergyDetailsPage({
    super.key,
    required this.allergyId,
    this.appointmentId,
  });

  @override
  State<AllergyDetailsPage> createState() => _AllergyDetailsPageState();
}

class _AllergyDetailsPageState extends State<AllergyDetailsPage> {
  @override
  void initState() {
    super.initState();
    _loadAllergyDetails();
  }

  void _loadAllergyDetails() {
    context.read<AllergyCubit>().getSpecificAllergy(
      allergyId: widget.allergyId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.primaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Allergy Details',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.whiteColor,
      ),
      body: BlocConsumer<AllergyCubit, AllergyState>(
        listener: (context, state) {
          if (state is AllergyError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red.shade400,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AllergyLoading) {
            return const Center(child: LoadingPage());
          } else if (state is AllergyDetailsSuccess) {
            return _buildAllergyDetails(state.allergyModel);
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load allergy details. Please try again.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _loadAllergyDetails,
                    child: const Text(
                      'Tap to retry',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primaryColor,
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

  Widget _buildAllergyDetails(AllergyModel allergy) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    allergy.name ?? 'Unknown Allergy',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _buildCriticalityChip(allergy.criticality),
              ],
            ),
          ),

          _buildInfoCard(
            title: 'Basic Information',
            children: [
              _buildDetailRow(
                context,
                Icons.info_outline,
                'Type',
                allergy.type?.display,
              ),
              _buildDetailRow(
                context,
                Icons.category_outlined,
                'Category',
                allergy.category?.display,
              ),
              _buildDetailRow(
                context,
                Icons.medical_services_outlined,
                'Clinical Status',
                allergy.clinicalStatus?.display,
              ),
              _buildDetailRow(
                context,
                Icons.verified_outlined,
                'Verification',
                allergy.verificationStatus?.display,
              ),
              _buildDetailRow(
                context,
                Icons.person_outline,
                'Onset Age',
                '${allergy.onSetAge ?? 'N/A'} years',
              ),
              if (allergy.lastOccurrence != null)
                _buildDetailRow(
                  context,
                  Icons.event_note_outlined,
                  'Last Occurrence',
                  DateFormat(
                    'MMM d, y',
                  ).format(DateTime.parse(allergy.lastOccurrence!)),
                ),
              if (allergy.note?.isNotEmpty ?? false)
                _buildDetailRow(
                  context,
                  Icons.notes_outlined,
                  'Notes',
                  allergy.note,
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (widget.appointmentId == null &&
              (allergy.reactions?.isNotEmpty ?? false)) ...[
            Text(
              'Reactions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allergy.reactions!.length,
              itemBuilder: (context, index) {
                final reaction = allergy.reactions![index];

                return ReactionListItem(
                  reaction: reaction,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ReactionDetailsPage(
                              allergyId: allergy.id!,
                              reactionId: reaction.id!,
                            ),
                      ),
                    ).then((_) => _loadAllergyDetails());
                  },
                );
              },
            ),
          ] else if (widget.appointmentId != null) ...[
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => AppointmentReactionsPage(
                            appointmentId: widget.appointmentId!,
                            allergyId: widget.allergyId,
                          ),
                    ),
                  ).then((_) => _loadAllergyDetails());
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'View All Reactions',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.primaryColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          if (allergy.encounter != null) ...[
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Encounter Information',
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => EncounterDetailsPage(
                              encounterId: allergy.encounter!.id!,
                            ),
                      ),
                    ).then((_) => _loadAllergyDetails());
                  },
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primaryColor,
                  ),
                  tooltip: 'View Encounter Details',
                ),
              ],
              children: [
                _buildDetailRow(
                  context,
                  Icons.local_hospital_outlined,
                  'Reason',
                  allergy.encounter?.reason,
                ),
                if (allergy.encounter?.actualStartDate != null)
                  _buildDetailRow(
                    context,
                    Icons.calendar_month_outlined,
                    'Date',
                    DateFormat('MMM d, y - h:mm a').format(
                      DateTime.parse(allergy.encounter!.actualStartDate!),
                    ),
                  ),
                if (allergy.encounter?.specialArrangement?.isNotEmpty ?? false)
                  _buildDetailRow(
                    context,
                    Icons.note_alt_outlined,
                    'Special Notes',
                    allergy.encounter?.specialArrangement,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    List<Widget>? actions,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (actions != null) Row(children: actions),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String? value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primaryColor.withOpacity(0.7)),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'Not specified',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalityChip(CodeModel? criticality) {
    Color chipColor;
    String displayText = criticality?.display ?? 'N/A';
    switch (criticality?.code?.toLowerCase()) {
      case 'high':
        chipColor = Colors.red.shade600;
        break;
      case 'moderate':
        chipColor = Colors.orange.shade600;
        break;
      case 'low':
        chipColor = Colors.green.shade600;
        break;
      default:
        chipColor = Colors.grey.shade500;
        displayText = 'N/A';
    }

    return Chip(
      label: Text(
        displayText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
  }
}
