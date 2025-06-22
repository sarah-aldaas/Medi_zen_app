import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/medical_records/encounter/data/models/encounter_model.dart';
import 'package:medizen_app/features/medical_records/imaging_study/presentation/pages/imaging_study_details_page.dart';
import 'package:medizen_app/features/medical_records/observation/data/models/observation_model.dart';
import 'package:medizen_app/features/medical_records/observation/presentation/pages/observation_details_page.dart';
import 'package:medizen_app/features/medical_records/service_request/data/models/service_request_model.dart';
import 'package:medizen_app/features/services/data/model/health_care_services_model.dart';
import '../../../imaging_study/data/models/imaging_study_model.dart';
import '../cubit/service_request_cubit/service_request_cubit.dart';

class ServiceRequestDetailsPage extends StatelessWidget {
  final String serviceId;

  const ServiceRequestDetailsPage({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service Request Details')),
      body: BlocConsumer<ServiceRequestCubit, ServiceRequestState>(
        listener: (context, state) {
          if (state is ServiceRequestError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ServiceRequestLoading && state.isDetailsLoading) {
            return  Center(child: LoadingPage());
          }

          if (state is ServiceRequestLoaded && state.serviceRequestDetails != null) {
            return _buildDetailsContent(context, state.serviceRequestDetails!);
          }

          return const Center(child: Text('No details available'));
        },
      ),
    );
  }

  Widget _buildDetailsContent(BuildContext context, ServiceRequestModel request) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Request Header
          _buildServiceHeader(context, request),
          const SizedBox(height: 24),

          // Service Details Section
          _buildServiceDetailsSection(request),
          const SizedBox(height: 24),

          // Observation Section
          if (request.observation != null) _buildObservationSection(request.observation!,context),
          if (request.observation != null) const SizedBox(height: 24),
          if (request.imagingStudy != null)
            _buildImagingStudySection(request.imagingStudy!,context),
          if (request.imagingStudy != null) const SizedBox(height: 24),
          // Encounter Section
          if (request.encounter != null) _buildEncounterSection(request.encounter!),
          if (request.encounter != null) const SizedBox(height: 24),

          // Healthcare Service Section
          if (request.healthCareService != null) _buildHealthcareServiceSection(request.healthCareService!),
        ],
      ),
    );
  }

  Widget _buildServiceHeader(BuildContext context, ServiceRequestModel request) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    request.healthCareService?.name ?? 'Unknown Service',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Chip(
                  backgroundColor: _getStatusColor(request.serviceRequestStatus?.code),
                  label: Text(request.serviceRequestStatus?.display ?? 'Unknown', style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (request.orderDetails != null) Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(request.orderDetails!)),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceDetailsSection(ServiceRequestModel request) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Service Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildDetailRow('Category', request.serviceRequestCategory?.display),
            _buildDetailRow('Priority', request.serviceRequestPriority?.display),
            if (request.serviceRequestBodySite != null) _buildDetailRow('Body Site', request.serviceRequestBodySite?.display),
            _buildDetailRow('Reason', request.reason),
            _buildDetailRow('Notes', request.note),
            if (request.occurrenceDate != null) _buildDetailRow('Request Date', DateFormat('MMM d, y - hh:mm a').format(request.occurrenceDate!)),
          ],
        ),
      ),
    );
  }

  Widget _buildObservationSection(ObservationModel observation,BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>ObservationDetailsPage(serviceId: serviceId, observationId: observation.id!)));
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Observations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              _buildDetailRow('Test Name', observation.observationDefinition?.title),
              _buildDetailRow('Result', observation.value),
              _buildDetailRow('Interpretation', observation.interpretation?.display),
              _buildDetailRow('Status', observation.status?.display),
              _buildDetailRow('Method', observation.method?.display),
              _buildDetailRow('Body Site', observation.bodySite?.display),
              _buildDetailRow('Notes', observation.note),
              if (observation.effectiveDateTime != null) _buildDetailRow('Date', DateFormat('MMM d, y - hh:mm a').format(observation.effectiveDateTime!)),
              if (observation.laboratory != null) ...[
                const SizedBox(height: 12),
                const Text('Laboratory Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Divider(),
                _buildDetailRow('Lab Specialist', '${observation.laboratory?.prefix} ${observation.laboratory?.given} ${observation.laboratory?.family}'),
                _buildDetailRow('Clinic', observation.laboratory?.clinic?.name),
              ],
              if (observation.pdf != null) ...[
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // Handle PDF view
                  },
                  child: const Text('View Test Report PDF'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEncounterSection(EncounterModel encounter) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Encounter Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildDetailRow('Type', encounter.type?.display),
            _buildDetailRow('Status', encounter.status?.display),
            _buildDetailRow('Reason', encounter.reason),
            if (encounter.actualStartDate != null)
              _buildDetailRow('Start Date', DateFormat('MMM d, y - hh:mm a').format(DateTime.parse(encounter.actualStartDate!))),
            if (encounter.actualEndDate != null) _buildDetailRow('End Date', DateFormat('MMM d, y - hh:mm a').format(DateTime.parse(encounter.actualEndDate!))),
            _buildDetailRow('Special Arrangements', encounter.specialArrangement),

            if (encounter.appointment != null) ...[
              const SizedBox(height: 12),
              const Text('Appointment Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Divider(),
              _buildDetailRow('Appointment Type', encounter.appointment?.type?.display),
              _buildDetailRow('Appointment Status', encounter.appointment?.status?.display),
              _buildDetailRow('Description', encounter.appointment?.description),
              _buildDetailRow('Notes', encounter.appointment?.note),

              if (encounter.appointment?.doctor != null) ...[
                const SizedBox(height: 12),
                const Text('Doctor Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Divider(),
                _buildDetailRow(
                  'Name',
                  '${encounter.appointment!.doctor!.prefix} ${encounter.appointment!.doctor!.given} ${encounter.appointment!.doctor!.family}',
                ),
                _buildDetailRow('Specialty', encounter.appointment!.doctor!.clinic?.name),
                _buildDetailRow('About', encounter.appointment!.doctor!.text),
              ],

              if (encounter.appointment?.patient != null) ...[
                const SizedBox(height: 12),
                const Text('Patient Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Divider(),
                _buildDetailRow(
                  'Name',
                  '${encounter.appointment!.patient!.prefix} ${encounter.appointment!.patient!.given} ${encounter.appointment!.patient!.family}',
                ),
                _buildDetailRow(
                  'Date of Birth',
                  encounter.appointment!.patient!.dateOfBirth != null
                      ? DateFormat('MMM d, y').format(DateTime.parse(encounter.appointment!.patient!.dateOfBirth!))
                      : null,
                ),
                _buildDetailRow('Gender', encounter.appointment!.patient!.gender?.display),
                _buildDetailRow('Blood Type', encounter.appointment!.patient!.bloodType?.display),
                _buildDetailRow('Marital Status', encounter.appointment!.patient!.maritalStatus?.display),
                _buildDetailRow('Height', encounter.appointment!.patient!.height != null ? '${encounter.appointment!.patient!.height} cm' : null),
                _buildDetailRow('Weight', encounter.appointment!.patient!.weight != null ? '${encounter.appointment!.patient!.weight} kg' : null),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHealthcareServiceSection(HealthCareServiceModel service) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Service Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildDetailRow('Category', service.category?.display),
            _buildDetailRow('Price', service.price != null ? '${service.price} ${service.price!.contains('\$') ? '' : '\$'}' : null),
            _buildDetailRow('Description', service.comment),
            _buildDetailRow('Additional Details', service.extraDetails),
            if (service.clinic != null) _buildDetailRow('Service Location', service.clinic?.name),
            if (service.photo != null) ...[
              const SizedBox(height: 12),
              Center(
                child: Image.network(
                  service.photo!,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [SizedBox(width: 150, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))), Expanded(child: Text(value))],
      ),
    );
  }
  Widget _buildImagingStudySection(ImagingStudyModel imagingStudy,BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>ImagingStudyDetailsPage(serviceId: serviceId, imagingStudyId: imagingStudy.id!)));
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Imaging Study',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Chip(
                    backgroundColor: _getImagingStatusColor(imagingStudy.status?.code),
                    label: Text(
                      imagingStudy.status?.display ?? 'Unknown',
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
              const Divider(),
              _buildDetailRow('Title', imagingStudy.title),
              _buildDetailRow('Description', imagingStudy.description),
              _buildDetailRow('Modality', imagingStudy.modality?.display),
              _buildDetailRow('Status', imagingStudy.status?.display),
              if (imagingStudy.started != null)
                _buildDetailRow(
                  'Started',
                  DateFormat('MMM d, y - hh:mm a').format(imagingStudy.started!),
                ),
              if (imagingStudy.cancelledReason != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Cancellation Reason', imagingStudy.cancelledReason),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Study was cancelled: ${imagingStudy.cancelledReason}',
                        style: TextStyle(color: Colors.red[800]),
                      ),
                    ),
                  ],
                ),

              if (imagingStudy.status?.description != null)
                Tooltip(
                  message: imagingStudy.status!.description,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          WidgetSpan(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: Icon(Icons.info_outline, size: 20),
                            ),
                          ),
                          TextSpan(
                            text: 'Status meaning: ${imagingStudy.status!.description}',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

// Add this to your status color method for imaging study statuses
  Color _getImagingStatusColor(String? statusCode) {
    switch (statusCode) {
      case 'registered':
        return Colors.blue;
      case 'preliminary':
        return Colors.orange;
      case 'final':
        return Colors.green;
      case 'amended':
        return Colors.purple;
      case 'cancelled':
        return Colors.red;
      case 'entered-in-error':
        return Colors.deepOrange;
      case 'unknown':
        return Colors.grey;
      default:
        return Colors.grey[600]!;
    }
  }

  Color _getStatusColor(String? statusCode) {
    switch (statusCode) {
      case 'active':
        return Colors.lightBlue;
      case 'on-hold':
        return Colors.orange;
      case 'revoked':
        return Colors.red[400]!;
      case 'entered-in-error':
        return Colors.purple;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.green;
      case 'in-progress':
        return Colors.blue;
      case 'cancelled':
        return Colors.red[800]!;
      default:
        return Colors.grey;
    }
  }
}
