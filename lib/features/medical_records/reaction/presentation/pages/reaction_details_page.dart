import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/data/models/code_type_model.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
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
        title: Text('reactionsPage.reactionDetails'.tr(context)), // Translated
        elevation: 0,
        backgroundColor: AppColors.whiteColor,
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
            return _buildReactionDetails(
              context,
              state.reactionModel,
            ); // Pass context
          } else {
            return Center(
              child: Text(
                'reactionsPage.failedToLoadReactionDetails'.tr(
                  context,
                ), // Translated
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildReactionDetails(BuildContext context, ReactionModel reaction) {
    // Added context
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  reaction.manifestation ??
                      'reactionsPage.unknownReaction'.tr(context), // Translated
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
              ),
              _buildSeverityChip(context, reaction.severity), // Pass context
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
                    'reactionsPage.basicInformation'.tr(context), // Translated
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context, // Pass context
                    'reactionsPage.substance'.tr(context), // Translated
                    reaction.substance,
                  ),
                  _buildDetailRow(
                    context, // Pass context
                    'reactionsPage.exposureRoute'.tr(context), // Translated
                    reaction.exposureRoute?.display,
                  ),
                  if (reaction.onSet != null)
                    _buildDetailRow(
                      context, // Pass context
                      'reactionsPage.onset'.tr(context), // Translated
                      DateFormat(
                        'MMM d, y - h:mm a',
                      ).format(DateTime.parse(reaction.onSet!)),
                    ),
                  if (reaction.description?.isNotEmpty ?? false)
                    _buildDetailRow(
                      context, // Pass context
                      'reactionsPage.description'.tr(context), // Translated
                      reaction.description,
                    ),
                  if (reaction.note?.isNotEmpty ?? false)
                    _buildDetailRow(
                      context, // Pass context
                      'reactionsPage.notes'.tr(context), // Translated
                      reaction.note,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String? value) {
    // Added context
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
              value ?? 'reactionsPage.notSpecified'.tr(context), // Translated
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityChip(BuildContext context, CodeModel? severity) {
    // Added context
    Color chipColor;
    String displayText;

    switch (severity?.code?.toLowerCase()) {
      // Ensure code is lowercased for consistent matching
      case 'mild':
        chipColor = Colors.green.shade400;
        displayText = 'reactionsPage.mild'.tr(context); // Translated
        break;
      case 'moderate':
        chipColor = Colors.orange.shade400;
        displayText = 'reactionsPage.moderate'.tr(context); // Translated
        break;
      case 'severe':
        chipColor = Colors.red.shade400;
        displayText = 'reactionsPage.severe'.tr(context); // Translated
        break;
      default:
        chipColor = Colors.grey.shade400;
        displayText = 'reactionsPage.unknown'.tr(context); // Translated
    }

    return Chip(
      label: Text(
        displayText,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
