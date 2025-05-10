import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/services/di/injection_container_common.dart';
import 'package:medizen_app/base/services/network/resource.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import 'package:medizen_app/features/profile/data/models/telecom_model.dart';
import 'package:medizen_app/features/profile/presentaiton/cubit/profile_cubit.dart';
import '../../data/data_sources/telecom_remote_data_sources.dart';
import '../../data/models/telecom_update_respons.dart';

part 'telecom_state.dart';

class TelecomCubit extends Cubit<TelecomState> {
  final TelecomRemoteDataSource remoteDataSource;

  TelecomCubit({required this.remoteDataSource}) : super(TelecomInitial());

  Future<void> fetchTelecoms({required String rank, required String paginationCount}) async {
    emit(TelecomLoading());
    final result = await remoteDataSource.getListAllTelecom(rank: rank, paginationCount: paginationCount);
    if (result is Success<TelecomsDataModel>) {
      emit(TelecomSuccess(telecoms: result.data.data));
    } else if (result is ResponseError<TelecomsDataModel>) {
      emit(TelecomError(error: result.message ?? 'Failed to fetch telecoms'));
    }
  }

  Future<void> createTelecom({required TelecomModel telecomModel}) async {
    emit(TelecomLoading());
    final result = await remoteDataSource.createTelecom(telecomModel: telecomModel);
    if (result is Success<TelecomResponseModel>) {
      if (result.data.status) {
        await fetchTelecoms(rank: '1', paginationCount: '100'); // Refresh list
      } else {
        ShowToast.showToastError(message: result.data.msg);
        emit(TelecomError(error: result.data.msg ?? 'Failed to create telecom'));
      }
    } else if (result is ResponseError<TelecomResponseModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to create telecom');
      emit(TelecomError(error: result.message ?? 'Failed to create telecom'));
    }
  }

  Future<void> updateTelecom({required String id, required TelecomModel telecomModel}) async {
    emit(TelecomLoading());
    final result = await remoteDataSource.updateTelecom(id: id, telecomModel: telecomModel);
    if (result is Success<TelecomResponseModel>) {
      if (result.data.status) {
        await fetchTelecoms(rank: '1', paginationCount: '100'); // Refresh list
      } else {
        ShowToast.showToastError(message: result.data.msg);
        emit(TelecomError(error: result.data.msg ?? 'Failed to update telecom'));
      }
    } else if (result is ResponseError<TelecomResponseModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to update telecom');
      emit(TelecomError(error: result.message ?? 'Failed to update telecom'));
    }
  }

  Future<void> deleteTelecom({required String id}) async {
    emit(TelecomLoading());
    final result = await remoteDataSource.deleteTelecom(id: id);
    if (result is Success<TelecomResponseModel>) {
      if (result.data.status) {
        await fetchTelecoms(rank: '1', paginationCount: '100'); // Refresh list
      } else {
        ShowToast.showToastError(message: result.data.msg);
        emit(TelecomError(error: result.data.msg ?? 'Failed to delete telecom'));
      }
    } else if (result is ResponseError<TelecomResponseModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to delete telecom');
      emit(TelecomError(error: result.message ?? 'Failed to delete telecom'));
    }
  }

  Future<TelecomModel?> showTelecom({required String id}) async {
    final result = await remoteDataSource.showTelecom(id: id);
    if (result is Success<TelecomModel>) {
      return result.data;
    } else if (result is ResponseError<TelecomModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to fetch telecom details');
      emit(TelecomError(error: result.message ?? 'Failed to fetch telecom details'));
      return null;
    }
    return null;
  }
}