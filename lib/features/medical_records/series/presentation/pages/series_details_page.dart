import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';

import '../../data/data_source/series_remote_data_source.dart';
import '../cubit/series_cubit/series_cubit.dart';
import 'full_screen_image_viewer.dart';

class SeriesDetailsPage extends StatefulWidget {
  final String serviceId;
  final String imagingStudyId;
  final String seriesId;

  const SeriesDetailsPage({super.key, required this.serviceId, required this.imagingStudyId, required this.seriesId});

  @override
  State<SeriesDetailsPage> createState() => _SeriesDetailsPageState();
}

class _SeriesDetailsPageState extends State<SeriesDetailsPage> {
  @override
  void initState() {
    context.read<SeriesCubit>().getSeriesDetails(serviceId: widget.serviceId, imagingStudyId: widget.imagingStudyId, seriesId: widget.seriesId,context: context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Series Details')),
      body: BlocBuilder<SeriesCubit, SeriesState>(
        builder: (context, state) {
          if (state is SeriesLoading) {
            return const Center(child: LoadingPage());
          }

          if (state is SeriesError) {
            return Center(child: Text(state.message));
          }

          if (state is SeriesLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Modality: ${state.series.bodySite?.display ?? 'Unknown'}'),
                  Text('Number of Instances: ${state.series.images.length ?? 0}'),
                  const SizedBox(height: 20),
                  const Text('Images:', style: TextStyle(fontWeight: FontWeight.bold)),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8.0, mainAxisSpacing: 8.0),
                    itemCount: state.series.images.length ?? 0,
                    itemBuilder: (context, index) {
                      final instance = state.series.images[index];
                      return GestureDetector(onTap: () => _viewImageFullScreen(context, instance), child: Image.network(instance, fit: BoxFit.cover));
                    },
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _viewImageFullScreen(BuildContext context, String imageUrl) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => FullScreenImageViewer(imageUrl: imageUrl)));
  }
}
