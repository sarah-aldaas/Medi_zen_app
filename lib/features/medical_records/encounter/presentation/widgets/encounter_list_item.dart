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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        encounter.reason ?? 'Encounter',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    _buildStatusChip(encounter.status),
                  ],
                ),
                const SizedBox(height: 8),
                if (encounter.type?.display != null)
                  Text(
                    encounter.type!.display!,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                const SizedBox(height: 8),
                if (encounter.actualStartDate != null)
                  Text(
                    DateFormat('MMM d, y - h:mm a').format(DateTime.parse(encounter.actualStartDate!)),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(CodeModel? status) {
    Color chipColor;
    switch (status?.code) {
      case 'planned':
        chipColor = Colors.blue.shade100;
        break;
      case 'in-progress':
        chipColor = Colors.orange.shade100;
        break;
      case 'completed':
        chipColor = Colors.green.shade100;
        break;
      case 'cancelled':
        chipColor = Colors.red.shade100;
        break;
      default:
        chipColor = Colors.grey.shade200;
    }

    return Chip(
      label: Text(
        status?.display ?? 'Unknown',
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 12,
        ),
      ),
      backgroundColor: chipColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}