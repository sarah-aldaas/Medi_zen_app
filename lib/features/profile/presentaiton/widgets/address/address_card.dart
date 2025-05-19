import 'package:flutter/material.dart';
import 'package:medizen_app/features/profile/data/models/address_model.dart';

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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  address.type?.display ?? 'Address',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              address.use?.display ?? 'Use',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              address.text ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${address.line}, ${address.district}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '${address.city}, ${address.state}, ${address.postalCode}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              address.country ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (address.startDate != null || address.endDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${address.startDate != null ? 'From: ${address.startDate}' : ''}'
                      '${address.endDate != null ? ' to: ${address.endDate}' : ' to continue'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}