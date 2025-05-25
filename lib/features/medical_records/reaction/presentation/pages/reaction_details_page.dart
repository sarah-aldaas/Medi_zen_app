import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/data/models/code_type_model.dart';
import 'package:medizen_app/base/theme/app_color.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/medical_records/reaction/data/models/reaction_model.dart';

import '../cubit/reaction_cubit/reaction_cubit.dart';

class ReactionDetailsPage extends StatefulWidget {
  final String allergyId;
  final String reactionId;

  const ReactionDetailsPage({
    super.key,
    required this.allergyId,
    required this.reactionId,
  });

  @override
  State<ReactionDetailsPage> createState() => _ReactionDetailsPageState();
}

class _ReactionDetailsPageState extends State<ReactionDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ReactionCubit>().getSpecificReaction(
      allergyId: widget.allergyId,
      reactionId: widget.reactionId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reaction Details'),
        elevation: 0,
        backgroundColor:AppColors.whiteColor,
        titleTextStyle: const TextStyle(
          color: AppColors.primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<ReactionCubit, ReactionState>(
        listener: (context, state) {
          if (state is ReactionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is ReactionLoading) {
            return const Center(child: LoadingPage());
          } else if (state is ReactionDetailsSuccess) {
            return _buildReactionDetails(state.reactionModel);
          } else {
            return const Center(
              child: Text(
                'Failed to load reaction details',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildReactionDetails(ReactionModel reaction) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  reaction.manifestation ?? 'Unknown Reaction',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
              ),
              _buildSeverityChip(reaction.severity),
            ],
          ),
          const SizedBox(height: 16),

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Basic Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Substance', reaction.substance),
                  _buildDetailRow(
                    'Exposure Route',
                    reaction.exposureRoute?.display,
                  ),
                  if (reaction.onSet != null)
                    _buildDetailRow(
                      'Onset',
                      DateFormat(
                        'MMM d, y - h:mm a',
                      ).format(DateTime.parse(reaction.onSet!)),
                    ),
                  if (reaction.description?.isNotEmpty ?? false)
                    _buildDetailRow('Description', reaction.description),
                  if (reaction.note?.isNotEmpty ?? false)
                    _buildDetailRow('Notes', reaction.note),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'Not specified',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityChip(CodeModel? severity) {
    Color chipColor;
    switch (severity?.code) {
      case 'mild':
        chipColor = Colors.green.shade400;
        break;
      case 'moderate':
        chipColor = Colors.orange.shade400;
        break;
      case 'severe':
        chipColor = Colors.red.shade400;
        break;
      default:
        chipColor = Colors.grey.shade400;
    }

    return Chip(
      label: Text(
        severity?.display ?? 'Unknown',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
