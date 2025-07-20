import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/organization/presentation/pages/qualification_page.dart';

import '../../../../base/theme/app_color.dart';
import '../../data/models/organization_model.dart';
import '../cubit/organization_cubit/organization_cubit.dart';

class OrganizationDetailsPage extends StatefulWidget {
  const OrganizationDetailsPage({super.key});

  @override
  State<OrganizationDetailsPage> createState() =>
      _OrganizationDetailsPageState();
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
      appBar: AppBar(
        title: Text(
          'organizationDetailsPage.title'.tr(context),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),

        elevation: 1,
      ),
      body: BlocConsumer<OrganizationCubit, OrganizationState>(
        listener: (context, state) {
          if (state is OrganizationError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          if (state is OrganizationLoading) {
            return const Center(child: LoadingPage());
          } else if (state is OrganizationDetailsSuccess) {
            return _buildOrganizationDetails(state.organization, context);
          } else if (state is OrganizationError) {
            return Center(child: Text(state.error));
          }
          return Center(
            child: Text('organizationDetailsPage.fetchingDetails'.tr(context)),
          );
        },
      ),
    );
  }

  Widget _buildOrganizationDetails(
      OrganizationModel organization,
      BuildContext context,
      ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 20.0),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    organization.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  if (organization.aliase.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${'organizationDetailsPage.alias'.tr(context)}: ${organization.aliase}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    organization.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),

          _buildDetailCard(
            context,
            'organizationDetailsPage.type'.tr(context),
            organization.type,
            Icons.category,
          ),
          _buildDetailCard(
            context,
            'organizationDetailsPage.phone'.tr(context),
            organization.phone,
            Icons.phone,
          ),
          _buildDetailCard(
            context,
            'organizationDetailsPage.address'.tr(context),
            organization.address,
            Icons.location_on,
          ),
          _buildDetailCard(
            context,
            'organizationDetailsPage.workingHours'.tr(context),
            '${organization.beginOfWork} - ${organization.endOfWork}',
            Icons.access_time,
          ),
          _buildDetailCard(
            context,
            'organizationDetailsPage.status'.tr(context),
            organization.active ? 'Active' : 'Inactive',
            organization.active
                ? Icons.check_circle_outline
                : Icons.cancel_outlined,
            valueColor: organization.active ? Colors.green : Colors.red,
          ),
          
          Gap(20),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            child: InkWell(
              onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>QualificationPage())).then((_){
                context.read<OrganizationCubit>().getOrganizationDetails(context: context);

              }),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                child: Row(
                  children: [
                    Icon(Icons.file_present, color: Theme.of(context).primaryColor),
                    const Gap(12),
                    Text(
                      "Qualifications",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailCard(
      BuildContext context,
      String label,
      String value,
      IconData icon, {
        Color? valueColor,
      }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color:
                      valueColor ??
                          Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}