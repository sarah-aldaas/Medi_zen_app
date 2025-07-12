import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';

import '../../../../../base/data/models/code_type_model.dart';
import '../../data/models/encounter_model.dart';

class EncounterListItem extends StatelessWidget {
  final EncounterModel encounter;
  final VoidCallback onTap;

  const EncounterListItem({
    super.key,
    required this.encounter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Color primaryColor = theme.primaryColor;
    final Color accentColor = theme.colorScheme.secondary;
    final Color titleColor =
        theme.textTheme.titleLarge?.color ?? Colors.black87;
    final Color subtitleColor =
        theme.textTheme.bodyMedium?.color ?? Colors.grey[700]!;

    final Color dateBackgroundColor = primaryColor.withOpacity(0.1);
    final Color dateTextColor = primaryColor;

    final String type =
        encounter.type?.display ?? 'encountersPge.encounter'.tr(context);
    final String scheduledDate =
        encounter.actualStartDate != null
            ? DateFormat(
              'MMM d, y - h:mm a',
            ).format(DateTime.parse(encounter.actualStartDate!))
            : 'encountersPge.dateNotAvailable'.tr(context);
    final String status =
        encounter.status?.display ?? 'encountersPge.unknownStatus'.tr(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        encounter.reason ??
                            'encountersPge.encounter'.tr(context),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: titleColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (encounter.type?.display != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          type,
                          style: TextStyle(color: subtitleColor, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (encounter.actualStartDate != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: dateBackgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            scheduledDate,
                            style: TextStyle(
                              color: dateTextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildStatusIcon(
                    context,
                    encounter.status,
                    accentColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(
    BuildContext context,
    CodeModel? status,
    Color accentColor,
  ) {
    IconData iconData;
    Color iconColor;
    String tooltipText;

    switch (status?.code) {
      case 'planned':
        iconData = Icons.event_note;
        iconColor = Colors.blue.shade700;
        tooltipText = 'encountersPge.planned'.tr(context);
        break;
      case 'in-progress':
        iconData = Icons.hourglass_full;
        iconColor = Colors.orange.shade700;
        tooltipText = 'encountersPge.inProgress'.tr(context);
        break;
      case 'completed':
        iconData = Icons.check_circle;
        iconColor = Colors.green.shade700;
        tooltipText = 'encountersPge.completed'.tr(context);
        break;
      case 'cancelled':
        iconData = Icons.cancel;
        iconColor = Colors.red.shade700;
        tooltipText = 'encountersPge.cancelled'.tr(context);
        break;
      default:
        iconData = Icons.help_outline;
        iconColor = accentColor.withOpacity(0.7);
        tooltipText = 'encountersPge.unknownStatus'.tr(context);
    }

    return Tooltip(
      message: tooltipText,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(iconData, color: iconColor, size: 24),
      ),
    );
  }
}
