import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/go_router/go_router.dart';
import 'package:medizen_app/features/services/data/model/health_care_services_model.dart';
import 'package:medizen_app/features/services/pages/health_care_service_details_page.dart';

import 'cubits/service_cubit/service_cubit.dart';

class HealthCareServicesPage extends StatefulWidget {
  const HealthCareServicesPage({super.key});

  @override
  State<HealthCareServicesPage> createState() => _HealthCareServicesPageState();
}

class _HealthCareServicesPageState extends State<HealthCareServicesPage> {
  final ScrollController _scrollController = ScrollController();
late ServiceCubit _cubit;
  @override
  void initState() {
    super.initState();
    // Load initial data
    _cubit= context.read<ServiceCubit>();
    _cubit.getAllServiceHealthCare();

    // Add scroll listener for infinite scroll (optional)
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      // Load more when scrolled to bottom
      _cubit.getAllServiceHealthCare(loadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Care Services')),
      body: BlocBuilder<ServiceCubit, ServiceState>(
        builder: (context, state) {
          if (state is ServiceHealthCareSuccess) {
            return _buildServicesList(state);
          } else if (state is ServiceHealthCareError) {
            return Center(child: Text(state.error));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildServicesList(ServiceHealthCareSuccess state) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: state.allServices.length + (state.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.allServices.length) {
                return const Center(child: CircularProgressIndicator());
              }
              return _buildServiceItem(state.allServices[index]);
            },
          ),
        ),
        // Optional: Add a load more button at the bottom
        if (state.hasMore && !_cubit.isLoadingServices)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                _cubit.getAllServiceHealthCare(loadMore: true);
              },
              child: const Text('Load More'),
            ),
          ),
      ],
    );
  }

  Widget _buildServiceItem(HealthCareServiceModel service) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: service.photo != null ? Image.network(service.photo!, width: 50, height: 50, fit: BoxFit.cover) : const Icon(Icons.medical_services, size: 50),
        title: Text(service.name!),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(service.comment!), Text('Price: \$${service.price}'), if (service.category != null) Text('Category: ${service.category!.display}')],
        ),
        trailing: service.appointmentRequired! ? const Icon(Icons.calendar_today) : const Icon(Icons.ac_unit),
        onTap: () {
          context.pushNamed(AppRouter.healthServiceDetails.name, extra: {"serviceId": service.id}).then((value) {
            _cubit.getAllServiceHealthCare();
          });
        },
      ),
    );
  }
}
