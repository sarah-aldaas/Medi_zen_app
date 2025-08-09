import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:medizen_app/base/services/network/resource.dart';
import 'package:medizen_app/features/medical_records/observation/data/models/observation_model.dart';
import '../../../data/data_source/observation_remote_data_source.dart';
part 'observation_state.dart';

class ObservationCubit extends Cubit<ObservationState> {
  final ObservationRemoteDataSource remoteDataSource;

  ObservationCubit({required this.remoteDataSource}) : super(ObservationInitial());

  Future<void> getObservationDetails({
    required String serviceId,
    required String observationId,
    required BuildContext context
  }) async {
    emit(ObservationLoading());

    final result = await remoteDataSource.getDetailsObservation(
      serviceId: serviceId,
      observationId: observationId,
    );

    if (result is Success<ObservationModel>) {
      emit(ObservationLoaded(result.data));
    } else {
      emit(ObservationError('Failed to load observation details'));
    }
  }
}