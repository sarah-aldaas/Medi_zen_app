import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../../../base/services/network/resource.dart';
import '../../../../series/data/data_source/series_remote_data_source.dart';
import '../../../data/data_source/imaging_study_remote_data_source.dart';
import '../../../data/models/imaging_study_model.dart';

part 'imaging_study_state.dart';

class ImagingStudyCubit extends Cubit<ImagingStudyState> {
  final ImagingStudyRemoteDataSource imagingStudyDataSource;
  final SeriesRemoteDataSource seriesDataSource;


  ImagingStudyCubit({required this.imagingStudyDataSource, required this.seriesDataSource}) : super(ImagingStudyInitial());

  Future<void> loadImagingStudy({required String serviceId, required String imagingStudyId, required BuildContext context}) async {
    emit(ImagingStudyLoading());

    final studyResult = await imagingStudyDataSource.getDetailsImagingStudy(serviceId: serviceId, imagingStudyId: imagingStudyId);
if(studyResult is Success<ImagingStudyModel>){
  emit(ImagingStudyLoaded(imagingStudy: studyResult.data));
}
    if (studyResult is! Success<ImagingStudyModel>) {
      emit(ImagingStudyError('Failed to load imaging study'));
      return;
    }
  }
  }
