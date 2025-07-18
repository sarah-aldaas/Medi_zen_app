import 'package:flutter/material.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/features/profile/data/models/address_model.dart';

import '../../../../../base/theme/app_color.dart';

class AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AddressCard({
    super.key,
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  address.type?.display ??
                      'addressCard.defaultAddressType'.tr(context),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              address.use?.display ??
                  'addressCard.defaultAddressUse'.tr(context),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 20),
            Text(
              address.text ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 20),
            Text(
              '${address.line}, ${address.district}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 20),
            Text(
              '${address.city}, ${address.state}, ${address.postalCode}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 20),
            Text(
              address.country ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (address.startDate != null || address.endDate != null)
              Padding(
                padding: EdgeInsets.only(top: 18),
                child: Text(
                  '${address.startDate != null ? 'addressCard.from'.tr(context) + ': ${address.startDate}' : ''}'
                  '${(address.endDate != null && address.endDate!.isNotEmpty && address.endDate != "null") ? ' ' + 'addressCard.to'.tr(context) + ': ${address.endDate}' : ' ' + 'addressCard.toContinue'.tr(context)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, size: 20, color: AppColors.gallery),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(Icons.delete, size: 20, color: AppColors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
