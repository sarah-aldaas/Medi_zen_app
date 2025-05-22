import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/features/medical_records/reaction/data/models/reaction_model.dart';

class ReactionListItem extends StatelessWidget {
  final ReactionModel reaction;
  final VoidCallback onTap;

  const ReactionListItem({
    super.key,
    required this.reaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      reaction.manifestation ?? 'Unknown Reaction',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  _buildSeverityChip(reaction),
                ],
              ),
              const SizedBox(height: 8),
              if (reaction.substance != null)
                Text(
                  'Substance: ${reaction.substance}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (reaction.exposureRoute?.display != null)
                    Text(
                      'Route: ${reaction.exposureRoute!.display}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  const Spacer(),
                  if (reaction.onSet != null)
                    Text(
                      'Onset: ${DateFormat('MMM y').format(DateTime.parse(reaction.onSet!))}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeverityChip(ReactionModel reaction) {
    Color chipColor;
    switch (reaction.severity?.code) {
      case 'mild':
        chipColor = Colors.green.shade100;
        break;
      case 'moderate':
        chipColor = Colors.orange.shade100;
        break;
      case 'severe':
        chipColor = Colors.red.shade100;
        break;
      default:
        chipColor = Colors.grey.shade200;
    }

    return Chip(
      label: Text(
        reaction.severity?.display ?? 'Unknown',
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 12,
        ),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}