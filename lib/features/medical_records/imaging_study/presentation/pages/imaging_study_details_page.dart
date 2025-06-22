import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/medical_records/imaging_study/presentation/cubit/imaging_study_cubit/imaging_study_cubit.dart';
import 'package:medizen_app/features/medical_records/observation/data/models/laboratory_model.dart';
import '../../../series/data/models/series_model.dart';
import '../../../series/presentation/pages/full_screen_image_viewer.dart';
import '../../../series/presentation/pages/series_details_page.dart';
import '../../../service_request/data/models/service_request_model.dart';
import '../../data/models/imaging_study_model.dart';

class ImagingStudyDetailsPage extends StatefulWidget {
  final String serviceId;
  final String imagingStudyId;

  const ImagingStudyDetailsPage({super.key, required this.serviceId, required this.imagingStudyId});

  @override
  State<ImagingStudyDetailsPage> createState() => _ImagingStudyDetailsPageState();
}

class _ImagingStudyDetailsPageState extends State<ImagingStudyDetailsPage> {
  @override
  void initState() {
    context.read<ImagingStudyCubit>().loadImagingStudy(serviceId: widget.serviceId, imagingStudyId: widget.imagingStudyId,context: context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Imaging Study Details')),
      body: BlocBuilder<ImagingStudyCubit, ImagingStudyState>(
        builder: (context, state) {
          if (state is ImagingStudyLoading) {
            return const Center(child: LoadingPage());
          }

          if (state is ImagingStudyError) {
            return Center(child: Text(state.message));
          }

          if (state is ImagingStudyLoaded) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildStudyDetailsCard(state.imagingStudy),
                  if (state.imagingStudy.serviceRequest != null) _buildServiceRequestCard(state.imagingStudy.serviceRequest!),
                  if (state.imagingStudy.radiology != null) _buildRadiologistCard(state.imagingStudy.radiology!),
                  _buildSeriesSection(context, state),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStudyDetailsCard(ImagingStudyModel study) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(study.title ?? 'Imaging Study', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildDetailRow('Description', study.description),
            _buildDetailRow('Modality', study.modality?.display),
            _buildDetailRow('Modality Description', study.modality?.description),
            _buildDetailRow('Status', study.status?.display),
            if (study.status?.description != null) _buildDetailRow('Status Meaning', study.status?.description),
            if (study.started != null) _buildDetailRow('Study Date', DateFormat('MMM d, y - hh:mm a').format(study.started!)),
            if (study.cancelledReason != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                    child: Text('Cancellation Reason: ${study.cancelledReason}', style: TextStyle(color: Colors.red[800])),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceRequestCard(ServiceRequestModel serviceRequest) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Service Request', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildDetailRow('Order Details', serviceRequest.orderDetails),
            _buildDetailRow('Reason', serviceRequest.reason),
            _buildDetailRow('Notes', serviceRequest.note),
            _buildDetailRow('Priority', serviceRequest.serviceRequestPriority?.display),
            _buildDetailRow('Status', serviceRequest.serviceRequestStatus?.display),
            if (serviceRequest.serviceRequestStatus?.description != null) _buildDetailRow('Status Meaning', serviceRequest.serviceRequestStatus?.description),
            _buildDetailRow('Category', serviceRequest.serviceRequestCategory?.display),
            _buildDetailRow('Body Site', serviceRequest.serviceRequestBodySite?.display),
          ],
        ),
      ),
    );
  }

  Widget _buildRadiologistCard(LaboratoryModel radiologist) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Radiologist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildDetailRow('Name', '${radiologist.prefix} ${radiologist.given} ${radiologist.family} ${radiologist.suffix}'),
            _buildDetailRow('Specialization', radiologist.text),
            _buildDetailRow('Email', radiologist.email),
            _buildDetailRow('Address', radiologist.address),
            if (radiologist.clinic != null) ...[
              _buildDetailRow('Clinic', radiologist.clinic!.name),
              _buildDetailRow('Clinic Description', radiologist.clinic!.description),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSeriesSection(BuildContext context, ImagingStudyLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Series (${state.imagingStudy.series!.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: state.imagingStudy.series!.length ,
          itemBuilder: (context, index) {
            if (index < state.imagingStudy.series!.length) {
              return _buildSeriesCard(context, state.imagingStudy.series![index]);
            } else {
              // context.read<ImagingStudyCubit>().loadMoreSeries(serviceId: widget.serviceId, imagingStudyId: widget.imagingStudyId);
              return const Padding(padding: EdgeInsets.all(16.0), child: Center(child: LoadingPage()));
            }
          },
        ),
      ],
    );
  }

  Widget _buildSeriesCard(BuildContext context, SeriesModel series) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SeriesDetailsPage(serviceId: widget.serviceId, imagingStudyId: widget.imagingStudyId, seriesId: series.id!),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(series.title ?? 'Series', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildDetailRow('Description', series.description),
              _buildDetailRow('Body Site', series.bodySite?.display),
              _buildDetailRow('Images Count', '(${series.images.length})'),
              if (series.images.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: series.images.length,
                      itemBuilder: (context, index) {
                        final instance = series.images[index];

                        return GestureDetector(
                          onTap: () => _viewImageFullScreen(context, instance),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Image.network(
                              instance,
                              width: 150,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(width: 150, color: Colors.grey[200], child: const Icon(Icons.broken_image)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [SizedBox(width: 120, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))), Expanded(child: Text(value))],
      ),
    );
  }

  void _viewImageFullScreen(BuildContext context, String imageUrl) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => FullScreenImageViewer(imageUrl: imageUrl)));
  }
}
