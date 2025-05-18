import 'package:bloc/bloc.dart';
import 'package:medizen_app/features/appointment/data/models/appointment_update_model.dart';
import 'package:medizen_app/features/appointment/data/models/days_work_doctor_model.dart';
import 'package:medizen_app/features/appointment/data/models/slots_model.dart';
import 'package:meta/meta.dart';
import 'package:flutter/foundation.dart';
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

  Future<void> geSlotsAppointment({required String practitionerId, required String date}) async {
    emit(SlotsAppointmentLoading());
    final result = await remoteDataSource.getAllSlots(practitionerId: practitionerId, date: date);
    if (result is Success<AllSlotModel>) {
      emit(SlotsAppointmentSuccess(listSlots: result.data.listSlots!));
    } else if (result is ResponseError<AllSlotModel>) {
      emit(AppointmentError(error: result.message ?? 'Failed to fetch slots'));
    }
  }

  Future<void> getDaysWorkDoctor({required String doctorId}) async {
    emit(DaysWorkDoctorLoading());
    final result = await remoteDataSource.getDaysWorkDoctor(doctorId: doctorId);
    if (result is Success<DaysWorkDoctorModel>) {
      emit(DaysWorkDoctorSuccess(days: result.data));
    } else if (result is ResponseError<DaysWorkDoctorModel>) {
      emit(AppointmentError(error: result.message ?? 'Failed to fetch days'));
    }
  }

  int _currentPage = 1;
  bool _hasMore = true;
  Map<String, dynamic> _currentFilters = {};
  List<AppointmentModel> _allAppointments = [];

  Future<void> getMyAppointment({Map<String, dynamic>? filters, bool loadMore = false}) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allAppointments = [];
      emit(AppointmentLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    final result = await remoteDataSource.getMyAppointment(filters: _currentFilters, page: _currentPage, perPage: 5);

    if (result is Success<PaginatedResponse<AppointmentModel>>) {
     try {
        _allAppointments.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty && result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(
          AppointmentSuccess(
            hasMore: _hasMore,
            paginatedResponse: PaginatedResponse<AppointmentModel>(
              paginatedData: PaginatedData<AppointmentModel>(items: _allAppointments),
              meta: result.data.meta,
              links: result.data.links,
            ),
          ),
        );
      }catch(e){
       emit(AppointmentError(error:result.data.msg ?? 'Failed to fetch Appointments'));

     }
    } else if (result is ResponseError<PaginatedResponse<AppointmentModel>>) {
      emit(AppointmentError(error: result.message ?? 'Failed to fetch Appointments'));
    }
  }

  Future<void> createAppointment({required AppointmentCreateModel appointmentModel}) async {
    emit(AppointmentLoading(isLoadMore: false));
    final result = await remoteDataSource.createAppointment(appointmentModel: appointmentModel);
    if (result is Success<PublicResponseModel>) {
      if (result.data.status) {
        emit(CreateAppointmentSuccess());
      } else {
        emit(AppointmentError(error: result.data.msg));
      }
    } else if (result is ResponseError<PublicResponseModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to create appointment');
      emit(AppointmentError(error: result.message ?? 'Failed to create appointment'));
    }
  }

  Future<void> updateAppointment({required String id, required AppointmentUpdateModel appointmentModel}) async {
    emit(AppointmentLoading(isLoadMore: false));
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

  Future<void> cancelAppointment({required String id, required String cancellationReason}) async {
    emit(AppointmentLoading(isLoadMore: false));
    final result = await remoteDataSource.cancelAppointment(id: id, cancellationReason: cancellationReason);
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

  Future<void> getDetailsAppointment({required String id}) async {
    emit(AppointmentLoading(isLoadMore: false));
    final result = await remoteDataSource.getDetailsAppointment(id: id);
    if (result is Success<AppointmentModel>) {
      emit(AppointmentDetailsSuccess(appointmentModel: result.data));
    } else if (result is ResponseError<AppointmentModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to fetch appointment details');
      emit(AppointmentError(error: result.message ?? 'Failed to fetch appointment details'));
    }
  }
}


