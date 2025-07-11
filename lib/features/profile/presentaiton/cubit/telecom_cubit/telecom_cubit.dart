import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/services/network/network_info.dart';
import 'package:medizen_app/base/services/network/resource.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import 'package:medizen_app/features/profile/data/models/telecom_model.dart';
import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/data/models/public_response_model.dart';
import '../../../../../base/go_router/go_router.dart';
import '../../../data/data_sources/telecom_remote_data_sources.dart';

part 'telecom_state.dart';

class TelecomCubit extends Cubit<TelecomState> {
  final TelecomRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo; // Add NetworkInfo dependency

  TelecomCubit({
    required this.remoteDataSource,
    required this.networkInfo,
  }) : super(TelecomInitial());

  Future<void> fetchTelecoms({
    required String rank,
    required String paginationCount,
    int page = 1,
    required BuildContext context,
  }) async {
    emit(TelecomLoading());

    // Check internet connectivity
    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed(AppRouter.noInternet.name);
    //   emit(TelecomError(error: 'No internet connection'));
    //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
    //   return;
    // }

    final result = await remoteDataSource.getListAllTelecom(
      rank: rank,
      paginationCount: paginationCount,
    );
    if (result is Success<PaginatedResponse<TelecomModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      emit(TelecomSuccess(paginatedResponse: result.data, currentPage: page));
    } else if (result is ResponseError<PaginatedResponse<TelecomModel>>) {
      emit(TelecomError(error: result.message ?? 'Failed to fetch telecoms'));
    }
  }

  Future<void> fetchNextPage() async {
    if (state is TelecomSuccess) {
      final currentState = state as TelecomSuccess;
      final nextPage = currentState.currentPage + 1;
      if (nextPage <= currentState.paginatedResponse.meta!.lastPage) {
        emit(TelecomLoading());
        // Check internet connectivity
        // final isConnected = await networkInfo.isConnected;
        // if (!isConnected) {
        //   emit(TelecomError(error: 'No internet connection'));
        //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
        //   return;
        // }


        final result = await remoteDataSource.getListAllTelecom(
          rank: '1',
          paginationCount: currentState.paginatedResponse.meta!.perPage.toString(),
        );
        if (result is Success<PaginatedResponse<TelecomModel>>) {
          emit(
            TelecomSuccess(
              paginatedResponse: result.data,
              currentPage: nextPage,
            ),
          );
        } else if (result is ResponseError<PaginatedResponse<TelecomModel>>) {
          emit(
            TelecomError(error: result.message ?? 'Failed to fetch next page'),
          );
        }
      }
    }
  }

  Future<void> fetchPreviousPage() async {
    if (state is TelecomSuccess) {
      final currentState = state as TelecomSuccess;
      final prevPage = currentState.currentPage - 1;
      if (prevPage >= 1) {
        emit(TelecomLoading());

        // Check internet connectivity
        // final isConnected = await networkInfo.isConnected;
        // if (!isConnected) {
        //   emit(TelecomError(error: 'No internet connection'));
        //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
        //   return;
        // }

        final result = await remoteDataSource.getListAllTelecom(
          rank: '1',
          paginationCount: currentState.paginatedResponse.meta!.perPage.toString(),
        );
        if (result is Success<PaginatedResponse<TelecomModel>>) {
          emit(
            TelecomSuccess(
              paginatedResponse: result.data,
              currentPage: prevPage,
            ),
          );
        } else if (result is ResponseError<PaginatedResponse<TelecomModel>>) {
          emit(
            TelecomError(
              error: result.message ?? 'Failed to fetch previous page',
            ),
          );
        }
      }
    }
  }
  Future<void> createTelecom({
    required TelecomModel telecomModel,
    required BuildContext context,
  }) async {
    emit(TelecomLoading());

    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   if (context.mounted) {
    //     context.pushNamed(AppRouter.noInternet.name);
    //   }
    //   emit(TelecomError(error: 'No internet connection'));
    //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
    //   return;
    // }

    final result = await remoteDataSource.createTelecom(telecomModel: telecomModel);
    await fetchTelecoms(rank: '1', paginationCount: '100', context: context);

    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first." && context.mounted) {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      if (result.data.status) {
      } else {
        ShowToast.showToastError(message: result.data.msg);
        emit(TelecomError(error: result.data.msg ?? 'Failed to create telecom'));
      }
    } else if (result is ResponseError<PublicResponseModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to create telecom');
      emit(TelecomError(error: result.message ?? 'Failed to create telecom'));
    }
  }
  Future<void> updateTelecom({
    required String id,
    required TelecomModel telecomModel,
    required BuildContext context,
  }) async {
    emit(TelecomLoading());

    // Check internet connectivity
    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed(AppRouter.noInternet.name);
    //   emit(TelecomError(error: 'No internet connection'));
    //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
    //   return;
    // }

    final result = await remoteDataSource.updateTelecom(
      id: id,
      telecomModel: telecomModel,
    );
    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      if (result.data.status) {
        await fetchTelecoms(rank: '1', paginationCount: '100', context: context);
      } else {
        ShowToast.showToastError(message: result.data.msg);
        emit(
          TelecomError(error: result.data.msg ?? 'Failed to update telecom'),
        );
        await fetchTelecoms(rank: '1', paginationCount: '100', context: context);

      }
    } else if (result is ResponseError<PublicResponseModel>) {
      ShowToast.showToastError(
        message: result.message ?? 'Failed to update telecom',
      );
      emit(TelecomError(error: result.message ?? 'Failed to update telecom'));
      await fetchTelecoms(rank: '1', paginationCount: '100', context: context);

    }
  }

  Future<void> deleteTelecom({
    required String id,
    required BuildContext context,
  }) async {
    emit(TelecomLoading());
    // Check internet connectivity
    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed(AppRouter.noInternet.name);
    //   emit(TelecomError(error: 'No internet connection'));
    //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
    //   return;
    // }

    final result = await remoteDataSource.deleteTelecom(id: id);
    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      if (result.data.status) {
        await fetchTelecoms(rank: '1', paginationCount: '100', context: context);
      } else {
        ShowToast.showToastError(message: result.data.msg);
        emit(
          TelecomError(error: result.data.msg ?? 'Failed to delete telecom'),
        );
        await fetchTelecoms(rank: '1', paginationCount: '100', context: context);

      }
    } else if (result is ResponseError<PublicResponseModel>) {
      ShowToast.showToastError(
        message: result.message ?? 'Failed to delete telecom',
      );
      emit(TelecomError(error: result.message ?? 'Failed to delete telecom'));
    }
  }

  Future<TelecomModel?> showTelecom({
    required String id,
    required BuildContext context, // Add context parameter
  }) async {
    emit(TelecomLoading());

    // Check internet connectivity
    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed(AppRouter.noInternet.name);
    //   emit(TelecomError(error: 'No internet connection'));
    //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
    //   return null;
    // }

    final result = await remoteDataSource.showTelecom(id: id);
    if (result is Success<TelecomModel>) {
      return result.data;
    } else if (result is ResponseError<TelecomModel>) {
      ShowToast.showToastError(
        message: result.message ?? 'Failed to fetch telecom details',
      );
      emit(
        TelecomError(
          error: result.message ?? 'Failed to fetch telecom details',
        ),
      );
      return null;
    }
    return null;
  }
}