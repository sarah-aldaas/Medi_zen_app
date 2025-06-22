import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/medical_records/observation/data/models/observation_model.dart';
import '../cubit/observation_cubit/observation_cubit.dart';

class ObservationDetailsPage extends StatefulWidget {
  final String serviceId;
  final String observationId;

  const ObservationDetailsPage({
    super.key,
    required this.serviceId,
    required this.observationId,
  });

  @override
  State<ObservationDetailsPage> createState() => _ObservationDetailsPageState();
}

class _ObservationDetailsPageState extends State<ObservationDetailsPage> {
  @override
  void initState() {
    context.read<ObservationCubit>().getObservationDetails(
      context: context,
      serviceId: widget.serviceId,
      observationId: widget.observationId,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Observation Details')),
      body: BlocBuilder<ObservationCubit, ObservationState>(
        builder: (context, state) {
          if (state is ObservationLoading) {
            return const Center(child: LoadingPage());
          }

          if (state is ObservationError) {
            return Center(child: Text(state.message));
          }

          if (state is ObservationLoaded) {
            return _buildObservationDetails(state.observation);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildObservationDetails(ObservationModel observation) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Observation Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    observation.observationDefinition?.title ?? 'Observation',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Value', observation.value),
                  _buildDetailRow('Interpretation', observation.interpretation?.display),
                  _buildDetailRow('Status', observation.status?.display),
                  _buildDetailRow('Method', observation.method?.display),
                  _buildDetailRow('Body Site', observation.bodySite?.display),
                  _buildDetailRow('Notes', observation.note),
                  if (observation.effectiveDateTime != null)
                    _buildDetailRow(
                      'Date',
                      DateFormat('MMM d, y - hh:mm a').format(observation.effectiveDateTime!),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // PDF Report
          if (observation.pdf != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Report',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _viewPdfReport(context, observation.pdf!),
                      child: const Text('View Full Report PDF'),
                    ),
                  ],
                ),
              ),
            ),
          if (observation.pdf != null) const SizedBox(height: 24),

          // Observation Definition
          if (observation.observationDefinition != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Definition',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    _buildDetailRow('Name', observation.observationDefinition?.name),
                    _buildDetailRow('Description', observation.observationDefinition?.description),
                    _buildDetailRow('Purpose', observation.observationDefinition?.purpose),
                    _buildDetailRow('Type', observation.observationDefinition?.type?.display),
                    _buildDetailRow('Classification', observation.observationDefinition?.classification?.display),
                    _buildDetailRow('Preferred Unit', observation.observationDefinition?.permittedUnit?.display),

                    // Qualified Values
                    if (observation.observationDefinition?.qualifiedValues.isNotEmpty ?? false) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Reference Ranges',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      ...observation.observationDefinition!.qualifiedValues.map((qv) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (qv.ageRange != null)
                                _buildDetailRow(
                                  'Age Range',
                                  '${qv.ageRange!.low?.value} - ${qv.ageRange!.high?.value} ${qv.ageRange!.low?.unit}',
                                ),
                              if (qv.valueRange != null)
                                _buildDetailRow(
                                  'Value Range',
                                  '${qv.valueRange!.low?.value} - ${qv.valueRange!.high?.value} ${qv.valueRange!.low?.unit}',
                                ),
                              _buildDetailRow('Applies To', qv.appliesTo?.display),
                              _buildDetailRow('Gender', qv.gender?.display),
                              _buildDetailRow('Context', qv.context?.display),
                              const SizedBox(height: 8),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ],
                ),
              ),
            ),
          if (observation.observationDefinition != null) const SizedBox(height: 24),

          // Laboratory Information
          if (observation.laboratory != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Laboratory Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    _buildDetailRow(
                      'Lab Specialist',
                      '${observation.laboratory!.prefix} ${observation.laboratory!.given} ${observation.laboratory!.family}',
                    ),
                    _buildDetailRow('Email', observation.laboratory!.email),
                    _buildDetailRow('Address', observation.laboratory!.address),
                    if (observation.laboratory!.clinic != null) ...[
                      _buildDetailRow('Clinic', observation.laboratory!.clinic!.name),
                      _buildDetailRow('Clinic Description', observation.laboratory!.clinic!.description),
                    ],
                  ],
                ),
              ),
            ),
          if (observation.laboratory != null) const SizedBox(height: 24),

          // Related Service Request
          if (observation.serviceRequest != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Related Service Request',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    _buildDetailRow('Order Details', observation.serviceRequest!.orderDetails),
                    _buildDetailRow('Reason', observation.serviceRequest!.reason),
                    _buildDetailRow('Priority', observation.serviceRequest!.serviceRequestPriority?.display),
                    _buildDetailRow('Status', observation.serviceRequest!.serviceRequestStatus?.display),
                    _buildDetailRow('Category', observation.serviceRequest!.serviceRequestCategory?.display),
                    _buildDetailRow('Body Site', observation.serviceRequest!.serviceRequestBodySite?.display),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _viewPdfReport(BuildContext context, String pdfUrl) {
    // Implement PDF viewing logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PDF Report'),
        content: Text('Would you like to view the report at $pdfUrl?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement PDF viewer navigation
              Navigator.pop(context);
            },
            child: const Text('View'),
          ),
        ],
      ),
    );
  }
}