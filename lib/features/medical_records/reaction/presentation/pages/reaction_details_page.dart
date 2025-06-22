import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/data/models/code_type_model.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/medical_records/reaction/data/models/reaction_model.dart';

import '../../../../../base/widgets/show_toast.dart';
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
      context: context
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('reactionsPage.reactionDetails'.tr(context)),
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        titleTextStyle:
        theme.appBarTheme.titleTextStyle?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ) ??
            TextStyle(
              color: theme.primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
        centerTitle: true,
        iconTheme: theme.appBarTheme.iconTheme,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocConsumer<ReactionCubit, ReactionState>(
        listener: (context, state) {
          if (state is ReactionError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is ReactionLoading) {
            return Center(child: LoadingPage());
          } else if (state is ReactionDetailsSuccess) {
            return _buildReactionDetails(context, state.reactionModel);
          } else {
            return Center(
              child: Text(
                'reactionsPage.failedToLoadReactionDetails'.tr(context),
                style: TextStyle(
                  fontSize: 16,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildReactionDetails(BuildContext context, ReactionModel reaction) {
    final ThemeData theme = Theme.of(context);
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
                      'reactionsPage.unknownReaction'.tr(context),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              _buildSeverityChip(context, reaction.severity),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            color: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'reactionsPage.basicInformation'.tr(context),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    'reactionsPage.substance'.tr(context),
                    reaction.substance,
                  ),
                  _buildDetailRow(
                    context,
                    'reactionsPage.exposureRoute'.tr(context),
                    reaction.exposureRoute?.display,
                  ),
                  if (reaction.onSet != null)
                    _buildDetailRow(
                      context,
                      'reactionsPage.onset'.tr(context),
                      DateFormat(
                        'MMM d, y - h:mm a',
                      ).format(DateTime.parse(reaction.onSet!)),
                    ),
                  if (reaction.description?.isNotEmpty ?? false)
                    _buildDetailRow(
                      context,
                      'reactionsPage.description'.tr(context),
                      reaction.description,
                    ),
                  if (reaction.note?.isNotEmpty ?? false)
                    _buildDetailRow(
                      context,
                      'reactionsPage.notes'.tr(context),
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
    final ThemeData theme = Theme.of(context);
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
                color: theme.textTheme.bodySmall?.color,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'reactionsPage.notSpecified'.tr(context),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityChip(BuildContext context, CodeModel? severity) {
    final ThemeData theme = Theme.of(context);
    Color chipColor;
    String displayText;

    switch (severity?.code?.toLowerCase()) {
      case 'mild':
        chipColor = Colors.green.shade400;
        displayText = 'reactionsPage.mild'.tr(context);
        break;
      case 'moderate':
        chipColor = Colors.orange.shade400;
        displayText = 'reactionsPage.moderate'.tr(context);
        break;
      case 'severe':
        chipColor = Colors.red.shade400;
        displayText = 'reactionsPage.severe'.tr(context);
        break;
      default:
        chipColor =
            theme.textTheme.bodySmall?.color?.withOpacity(0.5) ??
                Colors.grey.shade400;
        displayText = 'reactionsPage.unknown'.tr(context);
    }

    return Chip(
      label: Text(
        displayText,
        style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 12),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
