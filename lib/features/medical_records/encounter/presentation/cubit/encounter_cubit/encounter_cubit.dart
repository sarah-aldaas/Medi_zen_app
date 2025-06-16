import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/features/medical_records/encounter/data/data_source/encounter_remote_datasource.dart';
import 'package:meta/meta.dart';

import '../../../../../../base/data/models/pagination_model.dart';
import '../../../../../../base/go_router/go_router.dart';
import '../../../../../../base/services/network/resource.dart';
import '../../../../../../base/widgets/show_toast.dart';
import '../../../data/models/encounter_model.dart';

part 'encounter_state.dart';

class EncounterCubit extends Cubit<EncounterState> {
  final EncounterRemoteDataSource remoteDataSource;

  EncounterCubit({required this.remoteDataSource}) : super(EncounterInitial());

  int _currentPage = 1;
  bool _hasMore = true;
  Map<String, dynamic> _currentFilters = {};
  List<EncounterModel> _allEncounters = [];

  Future<void> getAllMyEncounter({Map<String, dynamic>? filters, bool loadMore = false,required BuildContext context}) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allEncounters = [];
      emit(EncounterLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    final result = await remoteDataSource.getAllMyEncounter(filters: _currentFilters, page: _currentPage, perPage: 10);

    if (result is Success<PaginatedResponse<EncounterModel>>) {
      if(result.data.msg=="Unauthorized. Please login first."){
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      try {
        _allEncounters.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty && result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(
          EncountersSuccess(
            hasMore: _hasMore,
            paginatedResponse: PaginatedResponse<EncounterModel>(
              paginatedData: PaginatedData<EncounterModel>(items: _allEncounters),
              meta: result.data.meta,
              links: result.data.links,
            ),
          ),
        );
      } catch (e) {
        emit(EncounterError(error: result.data.msg ?? 'Failed to fetch encounters'));
      }
    } else if (result is ResponseError<PaginatedResponse<EncounterModel>>) {
      emit(EncounterError(error: result.message ?? 'Failed to fetch encounters'));
    }
  }

  Future<void> getAllMyEncounterOfAppointment({required String appointmentId}) async {
    emit(EncounterLoading(isLoadMore: false));
    final result = await remoteDataSource.getAllMyEncounterOfAppointment(appointmentId: appointmentId);
    if (result is Success<EncounterModel>) {
      emit(EncounterOfAppointmentSuccess(encounterModel: result.data));
    } else if (result is ResponseError<EncounterModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to fetch encounter details');
      emit(EncounterError(error: result.message ?? 'Failed to fetch encounter details'));
    }
  }

  Future<void> getSpecificEncounter({required String encounterId}) async {
    emit(EncounterLoading(isLoadMore: false));
    final result = await remoteDataSource.getSpecificEncounter(encounterId: encounterId);
    if (result is Success<EncounterModel>) {
      emit(EncounterDetailsSuccess(encounterModel: result.data));
    } else if (result is ResponseError<EncounterModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to fetch encounter details');
      emit(EncounterError(error: result.message ?? 'Failed to fetch encounter details'));
    }
  }
}
