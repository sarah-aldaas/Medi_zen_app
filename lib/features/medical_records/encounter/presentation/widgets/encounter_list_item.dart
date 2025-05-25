import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    final Color dateBackgroundColor = Colors.blueGrey.shade50;
    final Color dateTextColor = Colors.blueGrey.shade700;

    final String type = encounter.type?.display ?? 'Routine check-up';
    final String scheduledDate =
        encounter.actualStartDate != null
            ? DateFormat(
              'MMM d, y - h:mm a',
            ).format(DateTime.parse(encounter.actualStartDate!))
            : 'Date not available';
    final String status = encounter.status?.display ?? 'Unknown';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        encounter.reason ?? 'Encounter',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (encounter.type?.display != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          type,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (encounter.actualStartDate != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: dateBackgroundColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            scheduledDate,
                            style: TextStyle(
                              color: dateTextColor,
                              fontSize: 15,
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
                  child: _buildStatusIcon(encounter.status),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(CodeModel? status) {
    IconData iconData;
    Color iconColor;
    String tooltipText;

    switch (status?.code) {
      case 'planned':
        iconData = Icons.event_note;
        iconColor = Colors.blue.shade600;
        tooltipText = 'Planned';

        break;
      case 'in-progress':
        iconData = Icons.hourglass_full;
        iconColor = Colors.orange.shade600;
        tooltipText = 'In Progress';
        break;
      case 'completed':
        iconData = Icons.check_circle;
        iconColor = Colors.green.shade600;
        tooltipText = 'Completed';
        break;
      case 'cancelled':
        iconData = Icons.cancel;
        iconColor = Colors.red.shade600;
        tooltipText = 'Cancelled';
        break;
      default:
        iconData = Icons.help_outline;
        iconColor = Colors.grey.shade500;
        tooltipText = 'Unknown Status';
    }

    return Tooltip(
      message: tooltipText,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(iconData, color: iconColor, size: 25),
      ),
    );
  }
}
