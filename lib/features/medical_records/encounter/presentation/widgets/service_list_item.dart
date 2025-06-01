import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/go_router/go_router.dart';

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  service.name ?? 'Service',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                IconButton(
                  onPressed: () {
                    context.pushNamed(
                      AppRouter.healthServiceDetails.name,
                      extra: {"serviceId": service.id},
                    );
                  },
                  icon: Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.15),
                      shape: BoxShape.circle,

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Theme.of(context).primaryColor,
                      size: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (service.category?.display != null)
              Text(
                service.category!.display!,
                style: TextStyle(color: Colors.grey[600]),
              ),
            const SizedBox(height: 4),
            if (service.comment != null)
              Text(service.comment!, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
