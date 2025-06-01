import 'package:flutter/material.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart'; // Ensure this is imported
import 'package:medizen_app/features/profile/data/models/telecom_model.dart';

import '../../../../../../../../../base/theme/app_color.dart';

Widget _buildDetailRow(BuildContext context, String titleKey, String? value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        Icon(Icons.circle_outlined, color: Theme.of(context).primaryColor),
        const SizedBox(width: 12),
        Text(
          titleKey.tr(context),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value ?? 'telecomPage.notAvailable'.tr(context),
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ],
    ),
  );
}

void showTelecomDetailsDialog({
  required BuildContext context,
  required TelecomModel telecom,
}) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'telecomPage.telecomDetails'.tr(context),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close, color: AppColors.blackColor),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow(
                  context,
                  "telecomPage.valueLabel",
                  telecom.value,
                ),
                const SizedBox(height: 20),
                _buildDetailRow(
                  context,
                  'telecomPage.typeLabel',
                  telecom.type?.display,
                ),
                const SizedBox(height: 20),
                _buildDetailRow(
                  context,
                  'telecomPage.useLabel',
                  telecom.use?.display,
                ),
                const SizedBox(height: 20),
                _buildDetailRow(
                  context,
                  'telecomPage.startDateLabel',
                  telecom.startDate,
                ),
                const SizedBox(height: 20),
                _buildDetailRow(
                  context,
                  'telecomPage.endDateLabel',
                  telecom.endDate,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'telecomPage.cancel'.tr(context),
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.whiteColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
  );
}
