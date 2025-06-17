import 'package:flutter/material.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/features/profile/data/models/telecom_model.dart';

Widget _buildDetailRow(BuildContext context, String titleKey, String? value) {
  final ThemeData theme = Theme.of(context);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        Icon(Icons.star_border_purple500_rounded, color: theme.primaryColor),
        const SizedBox(width: 12),
        Text(titleKey.tr(context), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(child: Text(value ?? 'telecomPage.notAvailable'.tr(context), style: theme.textTheme.bodyMedium)),
      ],
    ),
  );
}

void showTelecomDetailsDialog({required BuildContext context, required TelecomModel telecom}) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      final ThemeData theme = Theme.of(dialogContext);
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: theme.dialogTheme.backgroundColor,
        surfaceTintColor: theme.dialogTheme.surfaceTintColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'telecomPage.telecomDetails'.tr(context),
              style: theme.textTheme.titleLarge?.copyWith(color: theme.primaryColor, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(context, "telecomPage.valueLabel", telecom.value),
              const SizedBox(height: 20),
              _buildDetailRow(context, 'telecomPage.typeLabel', telecom.type?.display),
              const SizedBox(height: 20),
              _buildDetailRow(context, 'telecomPage.useLabel', telecom.use?.display),
              const SizedBox(height: 20),
              _buildDetailRow(context, 'telecomPage.startDateLabel', telecom.startDate),
              const SizedBox(height: 20),
              _buildDetailRow(context, 'telecomPage.endDateLabel', telecom.endDate),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close the dialog
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              'telecomPage.cancel'.tr(context),
              style: theme.textTheme.labelLarge?.copyWith(fontSize: 15, color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );
}
