import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';

import '../data/model/health_care_services_model.dart';
import 'cubits/service_cubit/service_cubit.dart';

class HealthCareServiceDetailsPage extends StatefulWidget {
  final String serviceId;

  const HealthCareServiceDetailsPage({super.key, required this.serviceId});

  @override
  State<HealthCareServiceDetailsPage> createState() => _HealthCareServiceDetailsPageState();
}

class _HealthCareServiceDetailsPageState extends State<HealthCareServiceDetailsPage> {
  @override
  void initState() {
    super.initState();
    // Fetch service details when the page loads
    context.read<ServiceCubit>().getSpecificServiceHealthCare(id: widget.serviceId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title:  Text('Service Details',style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 20
        ),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,color: Colors.grey,),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<ServiceCubit, ServiceState>(
        listener: (context, state) {
          if (state is ServiceHealthCareError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is ServiceHealthCareModelSuccess) {
            return _buildServiceDetails(state.healthCareServiceModel);
          } else if (state is ServiceHealthCareError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.error),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ServiceCubit>().getSpecificServiceHealthCare(id: widget.serviceId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildServiceDetails(HealthCareServiceModel service) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (service.photo != null)
            Center(
              child: Image.network(
                service.photo!,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.medical_services, size: 100),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            service.name!,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(service.comment!),
          const SizedBox(height: 16),
          const Divider(),
          Text(
            'Details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(service.extraDetails ?? 'No additional details'),
          const SizedBox(height: 16),
          const Divider(),
          Text(
            'Price: ${service.price}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          if (service.category != null) ...[
            const Divider(),
            Text(
              'Category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              service.category!.display,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(service.category!.description),
          ],
          const SizedBox(height: 16),
          if (service.clinic != null) ...[
            const Divider(),
            Text(
              'Clinic',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              service.clinic!.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(service.clinic!.description),
            if (service.clinic!.photo != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: CircleAvatar(
                  child: Image.network(
                    service.clinic!.photo!,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
          const SizedBox(height: 16),
          if (service.eligibilities != null && service.eligibilities!.isNotEmpty) ...[
            const Divider(),
            Text(
              'Eligibility Requirements',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ...service.eligibilities!.map((e) => Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                title: Text(e.display),
                subtitle: Text(e.description),
              ),
            )),
          ],
        ],
      ),
    );
  }
}