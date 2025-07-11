import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/services/network/network_info.dart';
import '../../../../../../base/data/models/pagination_model.dart';
import '../../../../../../base/go_router/go_router.dart';
import '../../../../../../base/services/network/resource.dart';
import '../../../../../base/data/models/public_response_model.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../../data/data_source/complain_remote_datasource.dart';
import '../../../data/models/complain_model.dart';

part 'complain_state.dart';

class ComplainCubit extends Cubit<ComplainState> {
  final ComplainRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ComplainCubit({required this.remoteDataSource, required this.networkInfo})
      : super(ComplainInitial());

  int _currentPage = 1;
  bool _hasMore = true;
  Map<String, dynamic> _currentFilters = {};
  List<ComplainModel> _allComplains = [];

  Future<void> getAllComplains({
    Map<String, dynamic>? filters,
    bool loadMore = false,
    required BuildContext context,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allComplains = [];
      emit(ComplainLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed('noInternet');
    //   emit(ComplainError(error: 'No internet connection'));
    //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
    //   return;
    // }

    final result = await remoteDataSource.getAllComplain(
      filters: _currentFilters,
      page: _currentPage,
      perPage: 10,
    );

    if (result is Success<PaginatedResponse<ComplainModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      try {
        _allComplains.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(ComplainSuccess(
          hasMore: _hasMore,
          paginatedResponse: PaginatedResponse<ComplainModel>(
            paginatedData: PaginatedData<ComplainModel>(items: _allComplains),
            meta: result.data.meta,
            links: result.data.links,
          ),
        ));
      } catch (e) {
        emit(ComplainError(error: result.data.msg ?? 'Failed to fetch complains'));
      }
    } else if (result is ResponseError<PaginatedResponse<ComplainModel>>) {
      emit(ComplainError(error: result.message ?? 'Failed to fetch complains'));
    }
  }

  Future<void> getComplainsForAppointment({
    required String appointmentId,
    Map<String, dynamic>? filters,
    bool loadMore = false,
    required BuildContext context,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allComplains = [];
      emit(ComplainLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed('noInternet');
    //   emit(ComplainError(error: 'No internet connection'));
    //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
    //   return;
    // }

    final result = await remoteDataSource.getAllComplainOfAppointment(
      appointmentId: appointmentId,
      filters: _currentFilters,
      page: _currentPage,
      perPage: 10,
    );

    if (result is Success<PaginatedResponse<ComplainModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      try {
        _allComplains.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(ComplainSuccess(
          hasMore: _hasMore,
          paginatedResponse: PaginatedResponse<ComplainModel>(
            paginatedData: PaginatedData<ComplainModel>(items: _allComplains),
            meta: result.data.meta,
            links: result.data.links,
          ),
        ));
      } catch (e) {
        emit(ComplainError(error: result.data.msg ?? 'Failed to fetch complains'));
      }
    } else if (result is ResponseError<PaginatedResponse<ComplainModel>>) {
      emit(ComplainError(error: result.message ?? 'Failed to fetch complains'));
    }
  }

  Future<void> getComplainDetails({
    required String complainId,
    required BuildContext context,
  }) async {
    emit(ComplainLoading());

    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed('noInternet');
    //   emit(ComplainError(error: 'No internet connection'));
    //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
    //   return;
    // }

    final result = await remoteDataSource.getDetailsComplain(complainId: complainId);
    if (result is Success<ComplainModel>) {
      emit(ComplainDetailsSuccess(complain: result.data));
    } else if (result is ResponseError<ComplainModel>) {
      emit(ComplainError(error: result.message ?? 'Failed to fetch complain details'));
    }
  }

  Future<void> createComplain({
    required String appointmentId,
    required ComplainModel complain,
    required BuildContext context,
  }) async {
    emit(ComplainLoading());

    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed('noInternet');
    //   emit(ComplainError(error: 'No internet connection'));
    //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
    //   return;
    // }

    final result = await remoteDataSource.createComplain(
      appointmentId: appointmentId,
      complain: complain,
    );

    if (result is Success<PublicResponseModel>) {
      if(result.data.status) {
        emit(ComplainActionSuccess(message: result.data.msg));
      }else{
        ShowToast.showToastError(message: result.data.msg ?? 'Failed to delete complain');

      }

    } else if (result is ResponseError<PublicResponseModel>) {
      emit(ComplainError(error: result.message ?? 'Failed to create complain'));
      ShowToast.showToastError(message: result.message ?? 'Failed to create complain');

    }
  }

  Future<void> respondToComplain({
    required String complainId,
    required String responseText,
    List<File>? attachments,
    required BuildContext context,
  }) async {
    emit(ComplainLoading());

    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed('noInternet');
    //   emit(ComplainError(error: 'No internet connection'));
    //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
    //   return;
    // }

    final result = await remoteDataSource.responseOnComplain(
      complainId: complainId,
      responseText: responseText,
      attachments: attachments,
    );

    if (result is Success<PublicResponseModel>) {
      if(result.data.status)
      {
        emit(ComplainActionSuccess(message: result.data.msg));
      }else{
        ShowToast.showToastError(message: result.data.msg);

      }
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(ComplainError(error: result.message ?? 'Failed to submit response'));
      ShowToast.showToastError(message: result.message ?? 'Failed to submit response');

    }
  }

  Future<void> getComplainResponses({
    required String complainId,
    required BuildContext context,
  }) async {
    emit(ComplainLoading());

    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed('noInternet');
    //   emit(ComplainError(error: 'No internet connection'));
    //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
    //   return;
    // }

    final result = await remoteDataSource.getResponseOfComplain(complainId: complainId);
    if (result is Success<List<ComplainResponseModel>>) {
      emit(ComplainResponsesSuccess(responses: result.data));
    } else if (result is ResponseError<List<ComplainResponseModel>>) {
      emit(ComplainError(error: result.message ?? 'Failed to fetch responses'));

    }
  }

  Future<void> closeComplain({
    required String complainId,
    required BuildContext context,
  }) async {
    emit(ComplainLoading());

    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed('noInternet');
    //   emit(ComplainError(error: 'No internet connection'));
    //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
    //   return;
    // }

    final result = await remoteDataSource.closeComplain(complainId: complainId);
    if (result is Success<PublicResponseModel>) {
      if(result.data.status){
        emit(ComplainActionSuccess(message: result.data.msg));
      }else{
      emit(ComplainError(error: result.data.msg));
      ShowToast.showToastError(message: result.data.msg);
  }
      } else if (result is ResponseError<PublicResponseModel>) {
      emit(ComplainError(error: result.message ?? 'Failed to close complain'));
    }
  }

  Future<void> deleteComplain({
    required String complainId,
    required BuildContext context,
  }) async {
    emit(ComplainLoading());

    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed('noInternet');
    //   emit(ComplainError(error: 'No internet connection'));
    //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
    //   return;
    // }

    final result = await remoteDataSource.deleteComplain(complainId: complainId);
    if (result is Success<PublicResponseModel>) {
      if(result.data.status){
        emit(ComplainActionSuccess(message: result.data.msg));

      }
      else{
        emit(ComplainError(error: result.data.msg));
        ShowToast.showToastError(message: result.data.msg);
      }
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(ComplainError(error: result.message ?? 'Failed to delete complain'));
      ShowToast.showToastError(message: result.message ?? 'Failed to delete complain');
    }
  }
}