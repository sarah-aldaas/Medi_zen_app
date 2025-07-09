import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';

import '../../data/models/organization_model.dart';
import '../cubit/organization_cubit/organization_cubit.dart';

class OrganizationDetailsPage extends StatefulWidget {
  const OrganizationDetailsPage({super.key});

  @override
  State<OrganizationDetailsPage> createState() => _OrganizationDetailsPageState();
}

class _OrganizationDetailsPageState extends State<OrganizationDetailsPage> {
  @override
  void initState() {
    context.read<OrganizationCubit>().getOrganizationDetails(context: context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organization Details')),
      body: BlocConsumer<OrganizationCubit, OrganizationState>(
        listener: (context, state) {
          if (state is OrganizationError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          if (state is OrganizationLoading) {
            return const Center(child: LoadingPage());
          } else if (state is OrganizationDetailsSuccess) {
            return _buildOrganizationDetails(state.organization);
          } else if (state is OrganizationError) {
            return Center(child: Text(state.error));
          }
          return const Center(child: Text('Fetching organization details...'));
        },
      ),
    );
  }

  Widget _buildOrganizationDetails(OrganizationModel organization) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailItem('Name', organization.name),
          _buildDetailItem('Alias', organization.aliase),
          _buildDetailItem('Description', organization.description),
          _buildDetailItem('Type', organization.type),
          _buildDetailItem('Phone', organization.phone),
          _buildDetailItem('Address', organization.address),
          _buildDetailItem('Working Hours', '${organization.beginOfWork} - ${organization.endOfWork}'),
          _buildDetailItem('Status', organization.active ? 'Active' : 'Inactive'),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const Divider(),
        ],
      ),
    );
  }
}
