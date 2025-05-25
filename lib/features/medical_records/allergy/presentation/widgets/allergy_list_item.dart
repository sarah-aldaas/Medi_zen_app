import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../base/theme/app_color.dart';
import '../../data/models/allergy_model.dart';

class AllergyListItem extends StatelessWidget {
  final AllergyModel allergy;
  final VoidCallback onTap;

  const AllergyListItem({
    super.key,
    required this.allergy,
    required this.onTap,
  });

  Widget _buildStatusIcon(String? clinicalStatus) {
    IconData iconData;
    Color iconColor;
    String tooltipText;

    if (clinicalStatus?.toLowerCase() == 'active') {
      iconData = Icons.check_circle;
      iconColor = Colors.green.shade500;
      tooltipText = 'Active Allergy';
    } else if (clinicalStatus?.toLowerCase() == 'inactive') {
      iconData = Icons.circle_outlined;
      iconColor = Colors.grey.shade500;
      tooltipText = 'Inactive Allergy';
    } else {
      iconData = Icons.help_outline;
      iconColor = Colors.blueGrey.shade300;
      tooltipText = 'Unknown Status';
    }

    return Tooltip(
      message: tooltipText,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(iconData, color: iconColor, size: 24),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      return DateFormat('MMM d, y').format(DateTime.parse(dateStr));
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
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
                        allergy.name ?? 'Unknown Allergy',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),

                    _buildStatusIcon(allergy.clinicalStatus?.display),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Icon(
                      Icons.medical_information_outlined,
                      size: 18,
                      color: AppColors.primaryColor.withOpacity(0.7),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      allergy.type?.display ?? 'Allergy',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: AppColors.primaryColor.withOpacity(0.7),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Last: ${_formatDate(allergy.lastOccurrence)}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(
                      Icons.child_care_outlined,
                      size: 18,
                      color: AppColors.primaryColor.withOpacity(0.7),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Onset: ${allergy.onSetAge ?? 'N/A'} yrs',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
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
}
