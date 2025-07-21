import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../base/data/models/pagination_model.dart';
import '../../../../../../base/go_router/go_router.dart';
import '../../../../../../base/services/network/resource.dart';
import '../../../../../../base/widgets/show_toast.dart';
import '../../../data/data_source/condition_remote_data_source.dart';
import '../../../data/models/conditions_model.dart';

part 'conditions_state.dart';

class ConditionsCubit extends Cubit<ConditionsState> {
  final ConditionRemoteDataSource remoteDataSource;

  ConditionsCubit({required this.remoteDataSource,})
      : super(ConditionsInitial());

  int _currentPage = 1;
  bool _hasMore = true;
  Map<String, dynamic> _currentFilters = {};
  List<ConditionsModel> _allConditions = [];

  Future<void> getAllConditions({
    Map<String, dynamic>? filters,
    bool loadMore = false,
    required BuildContext context,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allConditions = [];
      emit(ConditionsLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    final result = await remoteDataSource.getAllConditions(
      filters: _currentFilters,
      page: _currentPage,
      perPage: 10,
    );

    if (result is Success<PaginatedResponse<ConditionsModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      try {
        _allConditions.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(ConditionsSuccess(
          hasMore: _hasMore,
          paginatedResponse: PaginatedResponse<ConditionsModel>(
            paginatedData: PaginatedData<ConditionsModel>(items: _allConditions),
            meta: result.data.meta,
            links: result.data.links,
          ),
        ));
      } catch (e) {
        emit(ConditionsError(error: result.data.msg ?? 'Failed to fetch conditions'));
      }
    } else if (result is ResponseError<PaginatedResponse<ConditionsModel>>) {
      emit(ConditionsError(error: result.message ?? 'Failed to fetch conditions'));
    }
  }

  Future<void> getConditionsForAppointment({
    required String appointmentId,
    Map<String, dynamic>? filters,
    bool loadMore = false,
    required BuildContext context,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allConditions = [];
      emit(ConditionsLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    final result = await remoteDataSource.getAllConditionForAppointment(
      appointmentId: appointmentId,
      filters: _currentFilters,
      page: _currentPage,
      perPage: 10,
    );

    if (result is Success<PaginatedResponse<ConditionsModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      try {
        _allConditions.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(ConditionsSuccess(
          hasMore: _hasMore,
          paginatedResponse: PaginatedResponse<ConditionsModel>(
            paginatedData: PaginatedData<ConditionsModel>(items: _allConditions),
            meta: result.data.meta,
            links: result.data.links,
          ),
        ));
      } catch (e) {
        emit(ConditionsError(error: result.data.msg ?? 'Failed to fetch conditions'));
      }
    } else if (result is ResponseError<PaginatedResponse<ConditionsModel>>) {
      emit(ConditionsError(error: result.message ?? 'Failed to fetch conditions'));
    }
  }

  Future<void> getConditionDetails({
    required String conditionId,
    required BuildContext context,
  }) async {
    emit(ConditionsLoading());

    final result = await remoteDataSource.getDetailsConditions(conditionId: conditionId);
    if (result is Success<ConditionsModel>) {
      if (result.data.healthIssue == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      emit(ConditionDetailsSuccess(condition: result.data));
    } else if (result is ResponseError<ConditionsModel>) {
      emit(ConditionsError(error: result.message ?? 'Failed to fetch condition details'));
    }
  }
}