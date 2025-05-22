import 'package:flutter/material.dart';

import '../../../../services/data/model/health_care_services_model.dart';

class ServiceListItem extends StatelessWidget {
  final HealthCareServiceModel service;

  const ServiceListItem({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              service.name ?? 'Service',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            if (service.category?.display != null)
              Text(
                service.category!.display!,
                style: TextStyle(color: Colors.grey[600]),
              ),
            const SizedBox(height: 4),
            if (service.comment != null)
              Text(
                service.comment!,
                style: TextStyle(color: Colors.grey[600]),
              ),
          ],
        ),
      ),
    );
  }
}