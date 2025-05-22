import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/allergy_model.dart';


class AllergyListItem extends StatelessWidget {
  final AllergyModel allergy;
  final VoidCallback onTap;

  const AllergyListItem({
    super.key,
    required this.allergy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
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
                        allergy.name ?? 'Unknown Allergy',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    _buildStatusChip(allergy),
                  ],
                ),
                const SizedBox(height: 8),
                if (allergy.type?.display != null)
                  Text(
                    allergy.type!.display!,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (allergy.onSetAge != null)
                      Text(
                        'Onset: ${allergy.onSetAge} yrs',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    const Spacer(),
                    if (allergy.lastOccurrence != null)
                      Text(
                        'Last: ${DateFormat('MMM y').format(DateTime.parse(allergy.lastOccurrence!))}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(AllergyModel allergy) {
    Color chipColor;
    switch (allergy.clinicalStatus?.code) {
      case 'active':
        chipColor = Colors.red.shade100;
        break;
      case 'inactive':
        chipColor = Colors.green.shade100;
        break;
      default:
        chipColor = Colors.grey.shade200;
    }

    return Chip(
      label: Text(
        allergy.clinicalStatus?.display ?? 'Unknown',
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