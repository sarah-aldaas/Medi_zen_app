import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../../../base/services/network/resource.dart';
import '../../../data/data_source/series_remote_data_source.dart';
import '../../../data/models/series_model.dart';

part 'series_state.dart';

class SeriesCubit extends Cubit<SeriesState> {
  final SeriesRemoteDataSource remoteDataSource;

  SeriesCubit({required this.remoteDataSource,}) : super(SeriesInitial());

  Future<void> getSeriesDetails({required String serviceId, required String imagingStudyId, required String seriesId, required BuildContext context}) async {
    emit(SeriesLoading());

    final result = await remoteDataSource.getDetailsSeries(serviceId: serviceId, imagingStudyId: imagingStudyId, seriesId: seriesId);

    if (result is Success<SeriesModel>) {
      emit(SeriesLoaded(result.data));
    } else {
      emit(SeriesError('Failed to load series details'));
    }
  }
}
