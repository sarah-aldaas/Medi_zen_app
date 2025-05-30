import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';

import '../../../../../base/data/models/code_type_model.dart';
import '../../data/models/reaction_model.dart';

class ReactionListItem extends StatelessWidget {
  final ReactionModel reaction;
  final VoidCallback onTap;

  const ReactionListItem({
    super.key,
    required this.reaction,
    required this.onTap,
  });

  String _formatDateTime(BuildContext context, String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) {
      return 'reactionsPage.notApplicable'.tr(context); // Translated
    }
    try {
      final DateTime dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('MMM d, y - h:mm a').format(dateTime);
    } catch (e) {
      return 'reactionsPage.invalidDate'.tr(context); // Translated
    }
  }

  Widget _buildSeverityChip(BuildContext context, CodeModel? severity) {
    // Added context
    Color chipColor;
    String displayText;

    switch (severity?.code?.toLowerCase()) {
      case 'mild':
        chipColor = Colors.green.shade500;
        displayText = 'reactionsPage.mild'.tr(context); // Translated
        break;
      case 'moderate':
        chipColor = Colors.orange.shade500;
        displayText = 'reactionsPage.moderate'.tr(context); // Translated
        break;
      case 'severe':
        chipColor = Colors.red.shade500;
        displayText = 'reactionsPage.severe'.tr(context); // Translated
        break;
      default:
        chipColor = Colors.grey.shade500;
        displayText = 'reactionsPage.notApplicable'.tr(context); // Translated
    }

    return Chip(
      label: Text(
        displayText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color dateBackgroundColor = Colors.blueGrey.shade50;
    final Color dateTextColor = Colors.blueGrey.shade700;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        reaction.manifestation ??
                            'reactionsPage.unknownReaction'.tr(
                              context,
                            ), // Translated
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildSeverityChip(
                      context,
                      reaction.severity,
                    ), // Pass context
                  ],
                ),
                const SizedBox(height: 12),

                _buildInfoRow(
                  icon: Icons.science_outlined,
                  label: 'reactionsPage.substance'.tr(context), // Translated
                  value: reaction.substance,
                  context: context,
                ),
                const SizedBox(height: 8),

                _buildInfoRow(
                  icon: Icons.route_outlined,
                  label: 'reactionsPage.exposure'.tr(context), // Translated
                  value: reaction.exposureRoute?.display,
                  context: context,
                ),
                const SizedBox(height: 8),

                _buildInfoRowWithBackground(
                  icon: Icons.calendar_today_outlined,
                  label: 'reactionsPage.onset'.tr(context), // Translated
                  value: _formatDateTime(
                    context,
                    reaction.onSet,
                  ), // Pass context
                  context: context,
                ),
                const SizedBox(height: 8),

                if (reaction.description?.isNotEmpty ?? false)
                  _buildInfoRow(
                    icon: Icons.description_outlined,
                    label: 'reactionsPage.description'.tr(
                      context,
                    ), // Translated
                    value: reaction.description,
                    context: context,
                  ),
                if (reaction.description?.isNotEmpty ?? false)
                  const SizedBox(height: 8),

                if (reaction.note?.isNotEmpty ?? false)
                  _buildInfoRow(
                    icon: Icons.note_alt_outlined,
                    label: 'reactionsPage.notes'.tr(context), // Translated
                    value: reaction.note,
                    context: context,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String? value,
    required BuildContext context,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 90,
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
            value ?? 'reactionsPage.notSpecified'.tr(context), // Translated
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRowWithBackground({
    required IconData icon,
    required String label,
    required String? value,
    required BuildContext context,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 90,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value ?? 'reactionsPage.notSpecified'.tr(context), // Translated
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
