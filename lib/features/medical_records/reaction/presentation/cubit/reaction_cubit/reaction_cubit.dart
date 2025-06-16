import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/features/medical_records/reaction/data/data_source/reaction_remote_datasource.dart';
import 'package:meta/meta.dart';

import '../../../../../../base/data/models/pagination_model.dart';
import '../../../../../../base/go_router/go_router.dart';
import '../../../../../../base/services/network/resource.dart';
import '../../../../../../base/widgets/show_toast.dart';
import '../../../data/models/reaction_model.dart';

part 'reaction_state.dart';

class ReactionCubit extends Cubit<ReactionState> {
  final ReactionRemoteDataSource remoteDataSource;

  ReactionCubit({required this.remoteDataSource}) : super(ReactionInitial());

  int _currentPage = 1;
  bool _hasMore = true;
  Map<String, dynamic> _currentFilters = {};
  List<ReactionModel> _allReactions = [];

  Future<void> getAllReactionOfAppointment({
    Map<String, dynamic>? filters,
    bool loadMore = false,
    required String allergyId,
    required String appointmentId,required BuildContext context
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allReactions = [];
      emit(ReactionLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    final result = await remoteDataSource.getAllReactionOfAppointment(
      filters: _currentFilters,
      page: _currentPage,
      perPage: 5,
      appointmentId: appointmentId,
      allergyId: allergyId,
    );

    if (result is Success<PaginatedResponse<ReactionModel>>) {
      if(result.data.msg=="Unauthorized. Please login first."){
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      try {
        _allReactions.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty && result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(
          ReactionsOfAppointmentSuccess(
            hasMore: _hasMore,
            paginatedResponse: PaginatedResponse<ReactionModel>(
              paginatedData: PaginatedData<ReactionModel>(items: _allReactions),
              meta: result.data.meta,
              links: result.data.links,
            ),
          ),
        );
      } catch (e) {
        emit(ReactionError(error: result.data.msg ?? 'Failed to fetch reactions'));
      }
    } else if (result is ResponseError<PaginatedResponse<ReactionModel>>) {
      emit(ReactionError(error: result.message ?? 'Failed to fetch reactions'));
    }
  }

  Future<void> getSpecificReaction({required String allergyId, required String reactionId}) async {
    emit(ReactionLoading(isLoadMore: false));
    final result = await remoteDataSource.getSpecificReaction(allergyId: allergyId, reactionId: reactionId);
    if (result is Success<ReactionModel>) {
      emit(ReactionDetailsSuccess(reactionModel: result.data));
    } else if (result is ResponseError<ReactionModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to fetch reaction details');
      emit(ReactionError(error: result.message ?? 'Failed to fetch reaction details'));
    }
  }
}
