import 'package:bloc/bloc.dart';
import 'package:medizen_app/features/appointment/data/models/appointment_update_model.dart';
import 'package:medizen_app/features/appointment/data/models/slots_model.dart';
import 'package:meta/meta.dart';

import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/data/models/public_response_model.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../../data/datasource/appointment_remote_datasource.dart';
import '../../../data/models/appointment_create_model.dart';
import '../../../data/models/appointment_model.dart';

part 'appointment_state.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  final AppointmentRemoteDataSource remoteDataSource;

  AppointmentCubit({required this.remoteDataSource}) : super(AppointmentInitial());


  Future<void> geSlotsAppointment({required String practitionerId,required String date}) async {
    emit(AppointmentLoading());
    final result = await remoteDataSource.getAllSlots(practitionerId: practitionerId, date: date);
    if (result is Success<List<SlotModel>>) {
      emit(SlotsAppointmentSuccess(
        listSlots: result.data,
      ));
    } else if (result is ResponseError<List<SlotModel>>) {
      emit(AppointmentError(error: result.message ?? 'Failed to fetch Appointments'));
    }
  }

  Future<void> getMyAppointment() async {
    emit(AppointmentLoading());
    final result = await remoteDataSource.getMyAppointment();
    if (result is Success<PaginatedResponse<AppointmentModel>>) {
      emit(AppointmentSuccess(
        paginatedResponse: result.data,
      ));
    } else if (result is ResponseError<PaginatedResponse<AppointmentModel>>) {
      emit(AppointmentError(error: result.message ?? 'Failed to fetch Appointments'));
    }
  }

  Future<void> createAppointment({required AppointmentCreateModel appointmentModel}) async {
    emit(AppointmentLoading());
    final result = await remoteDataSource.createAppointment(appointmentModel: appointmentModel);
    if (result is Success<PublicResponseModel>) {
      if (result.data.status) {
        await getMyAppointment();
      } else {
        ShowToast.showToastError(message: result.data.msg);
        emit(AppointmentError(error: result.data.msg ));
      }
    } else if (result is ResponseError<PublicResponseModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to create appointment');
      emit(AppointmentError(error: result.message ?? 'Failed to create appointment'));
    }
  }

  Future<void> updateAppointment({required String id, required AppointmentUpdateModel appointmentModel}) async {
    emit(AppointmentLoading());
    final result = await remoteDataSource.updateAppointment(id: id, appointmentModel: appointmentModel);
    if (result is Success<PublicResponseModel>) {
      if (result.data.status) {
        await getMyAppointment();
      } else {
        ShowToast.showToastError(message: result.data.msg);
        emit(AppointmentError(error: result.data.msg));
      }
    } else if (result is ResponseError<PublicResponseModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to update appointment');
      emit(AppointmentError(error: result.message ?? 'Failed to update appointment'));
    }
  }

  Future<void> cancelAppointment({required String id,required String cancellationReason }) async {
    emit(AppointmentLoading());
    final result = await remoteDataSource.cancelAppointment(id: id,cancellationReason:cancellationReason );
    if (result is Success<PublicResponseModel>) {
      if (result.data.status) {
        await getMyAppointment();
      } else {
        ShowToast.showToastError(message: result.data.msg);
        emit(AppointmentError(error: result.data.msg));
      }
    } else if (result is ResponseError<PublicResponseModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to cancel appointment');
      emit(AppointmentError(error: result.message ?? 'Failed to cancel appointment'));
    }
  }

  Future<AppointmentModel?> getDetailsAppointment({required String id}) async {
    emit(AppointmentLoading());
    final result = await remoteDataSource.getDetailsAppointment(id: id);
    if (result is Success<AppointmentModel>) {
      return result.data;
    } else if (result is ResponseError<AppointmentModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to fetch appointment details');
      emit(AppointmentError(error: result.message ?? 'Failed to fetch appointment details'));
      return null;
    }
    return null;
  }
}